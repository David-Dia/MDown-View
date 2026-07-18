import SwiftUI

struct PreviewContentView: View {
    let document: PreviewDocument

    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        MarkdownWebView(
            document: document,
            appearance: resolvedAppearance
        )
        .preferredColorScheme(theme.mode.colorScheme)
        .background(backgroundColor)
    }

    private var resolvedAppearance: MarkdownAppearance {
        switch theme.mode {
        case .automatic:
            systemColorScheme == .dark ? .dark : .light
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    private var backgroundColor: Color {
        resolvedAppearance == .dark
            ? Color(nsColor: .windowBackgroundColor)
            : .white
    }
}
