import AppKit
import SwiftUI
import UniformTypeIdentifiers

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowManager = PreviewWindowManager()

    static func main() {
        let application = NSApplication.shared
        let visualTest = CommandLine.arguments.contains("--visual-test")
        application.setActivationPolicy(visualTest ? .regular : .accessory)
        let delegate = AppDelegate()
        application.delegate = delegate
        application.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        installMainMenu()

        let commandLineURLs = CommandLine.arguments.dropFirst().compactMap { argument -> URL? in
            let url = URL(fileURLWithPath: argument)
            return ["md", "markdown"].contains(url.pathExtension.lowercased()) ? url : nil
        }
        if !commandLineURLs.isEmpty {
            open(urls: commandLineURLs)
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map(URL.init(fileURLWithPath:))
        open(urls: urls)
        sender.reply(toOpenOrPrint: .success)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        open(urls: urls)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @objc private func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.title = "打开 Markdown 文件"
        panel.prompt = "打开"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [
            UTType(filenameExtension: "md"),
            UTType(filenameExtension: "markdown")
        ].compactMap { $0 }

        guard panel.runModal() == .OK else { return }
        open(urls: panel.urls)
    }

    @objc private func closeWindow(_ sender: Any?) {
        NSApplication.shared.keyWindow?.performClose(sender)
    }

    private func open(urls: [URL]) {
        let markdownURLs = urls.filter {
            ["md", "markdown"].contains($0.pathExtension.lowercased())
        }
        guard !markdownURLs.isEmpty else { return }

        windowManager.open(urls: markdownURLs)

        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "退出 MDown View",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let fileItem = NSMenuItem()
        let fileMenu = NSMenu(title: "文件")
        let openItem = fileMenu.addItem(
            withTitle: "打开…",
            action: #selector(openDocument(_:)),
            keyEquivalent: "o"
        )
        openItem.target = self
        let closeItem = fileMenu.addItem(
            withTitle: "关闭窗口",
            action: #selector(closeWindow(_:)),
            keyEquivalent: "w"
        )
        closeItem.target = self
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let editItem = NSMenuItem()
        let editMenu = NSMenu(title: "编辑")
        editMenu.addItem(withTitle: "拷贝", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)

        NSApplication.shared.mainMenu = mainMenu
    }
}

@MainActor
private final class PreviewWindowManager {
    private var controllers: [UUID: PreviewWindowController] = [:]
    private var recentOpenRequests: [String: Date] = [:]
    private var cascadeIndex = 0

    private let cascadeOffsets: [NSPoint] = [
        NSPoint(x: 0, y: 0),
        NSPoint(x: 28, y: -28),
        NSPoint(x: 56, y: -56),
        NSPoint(x: 84, y: -84),
        NSPoint(x: -28, y: -28),
        NSPoint(x: -56, y: -56),
        NSPoint(x: -84, y: -84),
        NSPoint(x: 28, y: -56),
        NSPoint(x: 56, y: -28),
        NSPoint(x: -28, y: -56),
        NSPoint(x: -56, y: -28)
    ]

    func open(urls: [URL]) {
        let now = Date()
        recentOpenRequests = recentOpenRequests.filter {
            now.timeIntervalSince($0.value) < 2
        }
        let uniqueURLs = urls.filter { url in
            let key = url.standardizedFileURL.path
            guard recentOpenRequests[key] == nil else { return false }
            recentOpenRequests[key] = now
            return true
        }
        guard !uniqueURLs.isEmpty else { return }
        MarkdownWebKitRuntime.shared.prewarm()

        Task { [weak self] in
            let documents = await Task.detached(priority: .userInitiated) {
                uniqueURLs.map(PreviewDocument.load(from:))
            }.value
            guard let self else { return }

            for document in documents {
                present(document)
            }
        }
    }

    private func present(_ document: PreviewDocument) {
        let id = UUID()
        let screen = NSApplication.shared.keyWindow?.screen ?? NSScreen.main
        let controller = PreviewWindowController(
            document: document,
            screen: screen,
            onClose: { [weak self] in self?.controllers[id] = nil }
        )
        position(controller.window, on: screen)
        controllers[id] = controller
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
    }

    private func position(_ window: NSWindow?, on screen: NSScreen?) {
        guard let window else { return }

        let visibleFrame = screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let centeredOrigin = NSPoint(
            x: visibleFrame.midX - window.frame.width / 2,
            y: visibleFrame.midY - window.frame.height / 2
        )
        let occupiedOrigins = controllers.values.compactMap { $0.window?.frame.origin }

        for attempt in cascadeOffsets.indices {
            let offsetIndex = (cascadeIndex + attempt) % cascadeOffsets.count
            let offset = cascadeOffsets[offsetIndex]
            let proposedOrigin = NSPoint(
                x: centeredOrigin.x + offset.x,
                y: centeredOrigin.y + offset.y
            )
            let origin = constrainedOrigin(
                proposedOrigin,
                windowSize: window.frame.size,
                visibleFrame: visibleFrame
            )
            let isOccupied = occupiedOrigins.contains {
                abs($0.x - origin.x) < 2 && abs($0.y - origin.y) < 2
            }

            guard !isOccupied else { continue }
            window.setFrameOrigin(origin)
            cascadeIndex = (offsetIndex + 1) % cascadeOffsets.count
            return
        }

        window.setFrameOrigin(
            constrainedOrigin(
                centeredOrigin,
                windowSize: window.frame.size,
                visibleFrame: visibleFrame
            )
        )
    }

    private func constrainedOrigin(
        _ origin: NSPoint,
        windowSize: NSSize,
        visibleFrame: NSRect
    ) -> NSPoint {
        NSPoint(
            x: min(max(origin.x, visibleFrame.minX), visibleFrame.maxX - windowSize.width),
            y: min(max(origin.y, visibleFrame.minY), visibleFrame.maxY - windowSize.height)
        )
    }
}

@MainActor
private final class PreviewWindowController: NSWindowController, NSWindowDelegate {
    private static let referenceContentSize = NSSize(width: 768, height: 1_072)
    private static let totalScreenMargin: CGFloat = 80

    private let onClose: () -> Void

    init(document: PreviewDocument, screen: NSScreen?, onClose: @escaping () -> Void) {
        self.onClose = onClose

        let contentSize = Self.defaultContentSize(for: screen)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.contentMinSize = NSSize(
            width: min(560, contentSize.width),
            height: min(700, contentSize.height)
        )
        window.title = document.fileURL.lastPathComponent
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.tabbingMode = .disallowed
        window.isReleasedWhenClosed = false

        let content = PreviewContentView(document: document)
        window.contentViewController = NSHostingController(rootView: content)

        let accessory = NSTitlebarAccessoryViewController()
        accessory.layoutAttribute = .right
        let themeView = NSHostingView(rootView: ThemeMenuView())
        themeView.frame = NSRect(x: 0, y: 0, width: 132, height: 30)
        accessory.view = themeView
        window.addTitlebarAccessoryViewController(accessory)
        window.setContentSize(contentSize)

        super.init(window: window)
        window.delegate = self
    }

    private static func defaultContentSize(for screen: NSScreen?) -> NSSize {
        let visibleFrame = screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1_440, height: 900)
        let availableWidth = max(1, visibleFrame.width - totalScreenMargin)
        let availableHeight = max(1, visibleFrame.height - totalScreenMargin)
        let scale = min(
            1,
            availableWidth / referenceContentSize.width,
            availableHeight / referenceContentSize.height
        )
        return NSSize(
            width: floor(referenceContentSize.width * scale),
            height: floor(referenceContentSize.height * scale)
        )
    }

    required init?(coder: NSCoder) {
        nil
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}

private struct ThemeMenuView: View {
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        Menu {
            Section("主题") {
                ForEach(ThemeMode.allCases) { mode in
                    Button {
                        theme.mode = mode
                    } label: {
                        Label(mode.title, systemImage: mode == theme.mode ? "checkmark" : mode.symbolName)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: theme.mode.symbolName)
                Text("调整外观")
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
                .font(.system(size: 12.5, weight: .medium))
                .lineLimit(1)
                .padding(.horizontal, 11)
                .frame(height: 26)
                .background(Color.primary.opacity(0.07), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.primary.opacity(0.22), lineWidth: 0.75)
                }
                .contentShape(Capsule())
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .padding(.horizontal, 4)
        .help("调整预览外观")
        .accessibilityLabel("调整外观，当前为\(theme.mode.title)")
    }
}
