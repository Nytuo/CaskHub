//
//  AppTheme.swift
//  CaskHub
//
//  Created by Ali Elsokary on 21/02/2026.
//

import AppKit
import Observation

enum AppStyle: String, CaseIterable, Identifiable {
    case native
    case classic

    static let storageKey = "appStyle"

    /// Observed so token reads inside view bodies re-render when the style changes.
    static var current: AppStyle {
        get { AppStyleState.shared.style }
        set { AppStyleState.shared.style = newValue }
    }

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .native: return String(localized: "Native")
        case .classic: return String(localized: "Classic")
        }
    }

    /// Upgraders keep Classic; only installs with no earlier CaskHub state start Native.
    static func resolveStored(in defaults: UserDefaults, hasPriorInstall: () -> Bool) -> AppStyle {
        if let raw = defaults.string(forKey: storageKey), let style = AppStyle(rawValue: raw) {
            return style
        }
        let style: AppStyle = hasPriorInstall() ? .classic : .native
        defaults.set(style.rawValue, forKey: storageKey)
        return style
    }

    // ponytail: heuristic; every earlier launch leaves prefs or app-owned caches behind, so a
    // user who wiped all of them reads as a new install
    static func hasPriorInstall(
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) -> Bool {
        if let bundleID = Bundle.main.bundleIdentifier,
           defaults.persistentDomain(forName: bundleID)?.isEmpty == false {
            return true
        }
        let roots = [FileManager.SearchPathDirectory.cachesDirectory, .applicationSupportDirectory]
            .compactMap { fileManager.urls(for: $0, in: .userDomainMask).first }
        return roots.contains { fileManager.fileExists(atPath: $0.appendingPathComponent("CaskHub").path) }
    }
}

@Observable
final class AppStyleState {
    static let shared = AppStyleState()
    var style: AppStyle = .classic
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String {
        rawValue
    }

    /// Localized label for display. `rawValue` stays language-independent because
    /// it is persisted in `@AppStorage("appTheme")`.
    var title: String {
        switch self {
        case .system: return String(localized: "System")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }

    static func apply(_ raw: String) {
        let app = NSApplication.shared
        switch AppTheme(rawValue: raw) ?? .system {
        case .system: app.appearance = nil
        case .light: app.appearance = NSAppearance(named: .aqua)
        case .dark: app.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
