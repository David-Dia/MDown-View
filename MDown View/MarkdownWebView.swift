import AppKit
import SwiftUI
import WebKit

nonisolated enum MarkdownAppearance: String, Sendable {
    case light
    case dark
}

struct PreviewDocument: Sendable {
    let fileURL: URL
    let markdown: String?
    let readError: String?

    nonisolated static func load(from url: URL) -> PreviewDocument {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let encodings: [String.Encoding] = [
                .utf8,
                .utf16,
                .utf16LittleEndian,
                .utf16BigEndian,
                .isoLatin1
            ]
            for encoding in encodings {
                if let string = String(data: data, encoding: encoding) {
                    return PreviewDocument(
                        fileURL: url,
                        markdown: string,
                        readError: nil
                    )
                }
            }
            throw CocoaError(.fileReadInapplicableStringEncoding)
        } catch {
            return PreviewDocument(
                fileURL: url,
                markdown: nil,
                readError: error.localizedDescription
            )
        }
    }
}

@MainActor
final class MarkdownWebKitRuntime {
    static let shared = MarkdownWebKitRuntime()

    private let dataStore = WKWebsiteDataStore.nonPersistent()
    private var prewarmedWebView: WKWebView?

    private init() {}

    func prewarm() {
        guard prewarmedWebView == nil else { return }
        let webView = makeConfiguredWebView()
        webView.loadHTMLString(
            "<!doctype html><meta charset=\"utf-8\"><body></body>",
            baseURL: nil
        )
        prewarmedWebView = webView
    }

    func takeWebView(navigationDelegate: WKNavigationDelegate) -> WKWebView {
        let webView = prewarmedWebView ?? makeConfiguredWebView()
        prewarmedWebView = nil
        webView.stopLoading()
        webView.navigationDelegate = navigationDelegate
        return webView
    }

    private func makeConfiguredWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = dataStore
        configuration.suppressesIncrementalRendering = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = true
        return webView
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let document: PreviewDocument
    let appearance: MarkdownAppearance

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        MarkdownWebKitRuntime.shared.takeWebView(
            navigationDelegate: context.coordinator
        )
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let signature = "\(document.fileURL.path)|\(appearance.rawValue)"
        guard context.coordinator.signature != signature else { return }
        context.coordinator.signature = signature

        context.coordinator.render(
            markdown: document.markdown,
            readError: document.readError,
            appearance: appearance,
            signature: signature,
            in: webView
        )
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.invalidate()
        webView.stopLoading()
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var signature: String?
        private var renderGeneration = 0

        func render(
            markdown: String?,
            readError: String?,
            appearance: MarkdownAppearance,
            signature: String,
            in webView: WKWebView
        ) {
            renderGeneration += 1
            let generation = renderGeneration

            DispatchQueue.global(qos: .userInitiated).async {
                let html: String
                if let markdown {
                    html = MarkdownDocumentRenderer.render(markdown, appearance: appearance)
                } else {
                    html = MarkdownDocumentRenderer.renderError(
                        title: "Unable to Open File",
                        message: readError ?? "The file could not be read.",
                        appearance: appearance
                    )
                }

                DispatchQueue.main.async { [weak self, weak webView] in
                    guard let self,
                          self.renderGeneration == generation,
                          self.signature == signature else {
                        return
                    }
                    webView?.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                }
            }
        }

        func invalidate() {
            renderGeneration += 1
            signature = nil
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if ["http", "https", "mailto"].contains(url.scheme?.lowercased() ?? "") {
                NSWorkspace.shared.open(url)
            }
            decisionHandler(.cancel)
        }
    }
}
