import AppKit
import SwiftUI
import UniformTypeIdentifiers

let markdownExtensions: Set<String> = ["md", "markdown"]

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowManager = PreviewWindowManager()
    private let isVisualTest = CommandLine.arguments.contains("--visual-test")

    static func main() {
        let application = NSApplication.shared
        let visualTest = CommandLine.arguments.contains("--visual-test")
        application.setActivationPolicy(visualTest ? .regular : .accessory)
        let delegate = AppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) {
            application.run()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        installMainMenu()

        let commandLineURLs = CommandLine.arguments.dropFirst().compactMap { argument -> URL? in
            let url = URL(fileURLWithPath: argument)
            return markdownExtensions.contains(url.pathExtension.lowercased()) ? url : nil
        }
        if !commandLineURLs.isEmpty {
            open(urls: commandLineURLs)
        }

        // Launched with no document to show (e.g. double-clicking the app icon
        // itself). As a background accessory app there's nothing to display,
        // so quit instead of sitting invisibly with no way to recover it.
        guard !isVisualTest else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            if NSApplication.shared.windows.isEmpty && windowManager.pendingOpenCount == 0 {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        open(urls: urls)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        windowManager.pendingOpenCount == 0
    }

    @objc private func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.title = "Open Markdown Files"
        panel.prompt = "Open"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = markdownExtensions.compactMap { UTType(filenameExtension: $0) }

        guard panel.runModal() == .OK else { return }
        open(urls: panel.urls)
    }

    @objc private func closeWindow(_ sender: Any?) {
        NSApplication.shared.keyWindow?.performClose(sender)
    }

    private func open(urls: [URL]) {
        let markdownURLs = urls.filter {
            markdownExtensions.contains($0.pathExtension.lowercased())
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
            withTitle: "Quit MDown View",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let fileItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        let openItem = fileMenu.addItem(
            withTitle: "Open…",
            action: #selector(openDocument(_:)),
            keyEquivalent: "o"
        )
        openItem.target = self
        let closeItem = fileMenu.addItem(
            withTitle: "Close Window",
            action: #selector(closeWindow(_:)),
            keyEquivalent: "w"
        )
        closeItem.target = self
        fileItem.submenu = fileMenu
        mainMenu.addItem(fileItem)

        let editItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)

        let viewItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Zoom In", action: Selector(("zoomIn:")), keyEquivalent: "+")
        viewMenu.addItem(withTitle: "Zoom Out", action: Selector(("zoomOut:")), keyEquivalent: "-")
        viewMenu.addItem(withTitle: "Actual Size", action: Selector(("resetZoom:")), keyEquivalent: "0")
        viewItem.submenu = viewMenu
        mainMenu.addItem(viewItem)

        let windowItem = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(
            withTitle: "Minimize",
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(
            withTitle: "Bring All to Front",
            action: #selector(NSApplication.arrangeInFront(_:)),
            keyEquivalent: ""
        )
        windowItem.submenu = windowMenu
        mainMenu.addItem(windowItem)
        NSApplication.shared.windowsMenu = windowMenu

        NSApplication.shared.mainMenu = mainMenu
    }
}

@MainActor
private final class PreviewWindowManager {
    private var controllers: [String: PreviewWindowController] = [:]
    private var pendingKeys: Set<String> = []
    private(set) var pendingOpenCount = 0
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
        var keysInThisBatch: Set<String> = []
        let uniqueURLs = urls.filter { keysInThisBatch.insert($0.standardizedFileURL.path).inserted }
        guard !uniqueURLs.isEmpty else { return }
        MarkdownWebKitRuntime.shared.prewarm()

        for url in uniqueURLs {
            let key = url.standardizedFileURL.path

            if let existing = controllers[key] {
                existing.window?.makeKeyAndOrderFront(nil)
                continue
            }
            guard !pendingKeys.contains(key) else { continue }
            pendingKeys.insert(key)
            pendingOpenCount += 1

            Task { [weak self] in
                let document = await Task.detached(priority: .userInitiated) {
                    PreviewDocument.load(from: url)
                }.value
                guard let self else { return }
                pendingKeys.remove(key)
                pendingOpenCount -= 1
                present(document, key: key)
            }
        }
    }

    private func present(_ document: PreviewDocument, key: String) {
        let screen = NSApplication.shared.keyWindow?.screen ?? NSScreen.main
        let controller = PreviewWindowController(
            document: document,
            screen: screen,
            onClose: { [weak self] in self?.controllers[key] = nil }
        )
        if !controller.restoredSavedFrame {
            position(controller.window, on: screen)
        }
        controllers[key] = controller
        controller.showWindow(nil)
    }

    private func position(_ window: NSWindow?, on screen: NSScreen?) {
        guard let window else { return }

        let visibleFrame = Self.visibleFrame(for: screen)
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
            let origin = Self.constrainedOrigin(
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
            Self.constrainedOrigin(centeredOrigin, windowSize: window.frame.size, visibleFrame: visibleFrame)
        )
    }

    static func visibleFrame(for screen: NSScreen?) -> NSRect {
        screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1_440, height: 900)
    }

    private static func constrainedOrigin(
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
    private static let referenceContentSize = NSSize(width: 900, height: 1_040)
    private static let totalScreenMargin: CGFloat = 80

    private let onClose: () -> Void
    let restoredSavedFrame: Bool

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
        let themeView = NSHostingView(rootView: ThemePickerView())
        themeView.frame = NSRect(x: 0, y: 0, width: 174, height: 30)
        accessory.view = themeView
        window.addTitlebarAccessoryViewController(accessory)

        // Size the window LAST: setting an NSHostingController as the content
        // view controller resizes the window down to the SwiftUI view's fitting
        // size, so any sizing done before this gets clobbered.
        window.setContentSize(contentSize)
        let autosaveName = "Preview-" + document.fileURL.standardizedFileURL.path
        restoredSavedFrame = window.setFrameUsingName(autosaveName)
        window.setFrameAutosaveName(autosaveName)

        super.init(window: window)
        window.delegate = self
    }

    private static func defaultContentSize(for screen: NSScreen?) -> NSSize {
        let visibleFrame = PreviewWindowManager.visibleFrame(for: screen)
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

private struct ThemePickerView: View {
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        HStack(spacing: 2) {
            ForEach(ThemeMode.allCases) { mode in
                Button {
                    theme.mode = mode
                } label: {
                    Text(mode.title)
                        .font(.system(size: 11.5, weight: mode == theme.mode ? .semibold : .medium))
                        .foregroundStyle(mode == theme.mode ? .primary : .secondary)
                        .frame(minWidth: mode == .system ? 54 : 42)
                        .frame(height: 22)
                        .background {
                            if mode == theme.mode {
                                Capsule()
                                    .fill(Color.primary.opacity(0.12))
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("Use \(mode.title.lowercased()) appearance")
                .accessibilityLabel("\(mode.title) appearance")
                .accessibilityValue(mode == theme.mode ? "Selected" : "Not selected")
            }
        }
        .padding(2)
        .background(Color.primary.opacity(0.055), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.primary.opacity(0.18), lineWidth: 0.75)
        }
        .contentShape(Capsule())
        .fixedSize()
        .padding(.horizontal, 4)
        .preferredColorScheme(theme.mode.colorScheme)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Appearance")
    }
}
