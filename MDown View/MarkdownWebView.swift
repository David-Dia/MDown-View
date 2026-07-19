import AppKit
import SwiftUI
import WebKit

nonisolated enum MarkdownAppearance: String, Sendable {
    case light
    case dark
}

enum PreviewContent: Sendable {
    case loaded(String)
    case failed(String)
}

struct PreviewDocument: Sendable {
    let fileURL: URL
    let content: PreviewContent

    nonisolated private static let maximumFileSize = 20 * 1024 * 1024 // 20 MB

    nonisolated static func load(from url: URL) -> PreviewDocument {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size <= maximumFileSize else {
                throw CocoaError(.fileReadTooLarge)
            }

            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let gb18030 = String.Encoding(
                rawValue: CFStringConvertEncodingToNSStringEncoding(
                    CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
                )
            )
            // UTF-16 decodes almost any even-length byte stream into garbage, so
            // only attempt it when a real byte-order mark says so — otherwise a
            // GB18030/Latin-1 file gets mojibake'd before the byte-oriented
            // encodings below ever get a turn.
            var encodings: [String.Encoding] = [.utf8]
            let bom = Array(data.prefix(2))
            if bom == [0xFF, 0xFE] || bom == [0xFE, 0xFF] {
                encodings.append(.utf16)
            }
            encodings.append(contentsOf: [gb18030, .isoLatin1])
            for encoding in encodings {
                if let string = String(data: data, encoding: encoding) {
                    return PreviewDocument(fileURL: url, content: .loaded(string))
                }
            }
            throw CocoaError(.fileReadInapplicableStringEncoding)
        } catch {
            return PreviewDocument(fileURL: url, content: .failed(error.localizedDescription))
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
        webView.underPageBackgroundColor = .clear
        webView.allowsMagnification = true
        return webView
    }
}

extension WKWebView {
    @objc func zoomIn(_ sender: Any?) {
        pageZoom = min(pageZoom + 0.1, 3.0)
    }

    @objc func zoomOut(_ sender: Any?) {
        pageZoom = max(pageZoom - 0.1, 0.5)
    }

    @objc func resetZoom(_ sender: Any?) {
        pageZoom = 1.0
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
        let coordinator = context.coordinator
        if coordinator.documentPath != document.fileURL.path {
            coordinator.documentPath = document.fileURL.path
            coordinator.appearance = appearance
            coordinator.render(content: document.content, appearance: appearance, in: webView)
        } else if coordinator.appearance != appearance {
            coordinator.appearance = appearance
            coordinator.render(content: document.content, appearance: appearance, in: webView)
        }
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.invalidate()
        webView.stopLoading()
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var documentPath: String?
        var appearance: MarkdownAppearance?
        private var renderGeneration = 0

        func render(content: PreviewContent, appearance: MarkdownAppearance, in webView: WKWebView) {
            renderGeneration += 1
            let generation = renderGeneration
            let path = documentPath

            DispatchQueue.global(qos: .userInitiated).async {
                let html: String
                switch content {
                case .loaded(let markdown):
                    html = MarkdownDocumentRenderer.render(markdown, appearance: appearance)
                case .failed(let message):
                    html = MarkdownDocumentRenderer.renderError(
                        title: "Unable to Open File",
                        message: message,
                        appearance: appearance
                    )
                }

                DispatchQueue.main.async { [weak self, weak webView] in
                    guard let self,
                          self.renderGeneration == generation,
                          self.documentPath == path else {
                        return
                    }
                    webView?.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                }
            }
        }

        func invalidate() {
            renderGeneration += 1
            documentPath = nil
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
                decisionHandler(.cancel)
                return
            }

            if let currentURL = webView.url, isSamePage(url, currentURL) {
                decisionHandler(.allow) // in-page anchor jump
                return
            }

            decisionHandler(.cancel)
        }

        private func isSamePage(_ a: URL, _ b: URL) -> Bool {
            var aComponents = URLComponents(url: a, resolvingAgainstBaseURL: true)
            var bComponents = URLComponents(url: b, resolvingAgainstBaseURL: true)
            aComponents?.fragment = nil
            bComponents?.fragment = nil
            return aComponents?.url == bComponents?.url
        }
    }
}
