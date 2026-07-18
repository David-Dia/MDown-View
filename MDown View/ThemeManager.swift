import AppKit
import Combine
import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "自动"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var symbolName: String {
        switch self {
        case .automatic: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var mode: ThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.defaultsKey)
        }
    }

    private static let defaultsKey = "themeMode"

    private init() {
        let savedValue = UserDefaults.standard.string(forKey: Self.defaultsKey)
        mode = ThemeMode(rawValue: savedValue ?? "") ?? .automatic
    }
}
