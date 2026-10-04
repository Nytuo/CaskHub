//
//  LaunchCard.swift
//  CaskHub
//
//  Created by Ali Elsokary on 04/10/2026.
//

import Foundation

struct WhatsNewRelease: Equatable {
    struct Feature: Equatable {
        let symbol: String
        let title: LocalizedStringResource
        let detail: LocalizedStringResource
    }

    let version: String
    let features: [Feature]

    static let latest = WhatsNewRelease(version: "0.9.0", features: [
        Feature(
            symbol: "paintbrush",
            title: .launchCardWhatsNewStandardLookTitle,
            detail: .launchCardWhatsNewStandardLookDetail
        ),
        Feature(
            symbol: "macwindow",
            title: .launchCardWhatsNewToolbarTitle,
            detail: .launchCardWhatsNewToolbarDetail
        ),
        Feature(
            symbol: "app.badge.checkmark",
            title: .launchCardWhatsNewIconsTitle,
            detail: .launchCardWhatsNewIconsDetail
        )
    ])
}

enum LaunchCard: Identifiable, Equatable {
    case welcome
    case whatsNew(WhatsNewRelease)

    var id: String {
        switch self {
        case .welcome: "welcome"
        case let .whatsNew(release): "whatsNew.\(release.version)"
        }
    }
}

enum LaunchCardGate {
    static let lastSeenVersionKey = "launchCardLastSeenVersion"
    static let previewKey = "launchCardPreview"

    static func resolve(
        in defaults: UserDefaults,
        currentVersion: String,
        hasPriorInstall: Bool,
        latest: WhatsNewRelease
    ) -> LaunchCard? {
        switch defaults.string(forKey: previewKey) {
        case "welcome": return .welcome
        case "whatsNew": return .whatsNew(latest)
        default: break
        }

        let stored = defaults.string(forKey: lastSeenVersionKey)
        defaults.set(currentVersion, forKey: lastSeenVersionKey)
        if stored == nil, !hasPriorInstall { return .welcome }

        let isUnseen = NumericVersionComparison.compare(latest.version, stored ?? "0") == .orderedDescending
        let isShipped = NumericVersionComparison.compare(latest.version, currentVersion)
            .map { $0 != .orderedDescending } ?? false
        return isUnseen && isShipped ? .whatsNew(latest) : nil
    }
}
