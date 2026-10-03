//
//  TypographyTokens.swift
//  CaskHub
//
//  Created by Ali Elsokary on 07/07/2026.
//

import SwiftUI

enum CHType {
    static let displayFamily = "Baloo 2"
    static let uiFamily = "Nunito"
    static let monoFamily = "JetBrains Mono"

    /// Native swaps the display and UI faces for SF Pro; mono stays for data.
    static var isNative: Bool {
        AppStyle.current == .native
    }

    // Display — wordmark, screen titles, section heads
    static var heroTitle: Font { Catalog(scale: 1).hero }
    static var section: Font {
        isNative ? .system(size: 15, weight: .bold) : Font.custom(displayFamily, size: 16).weight(.heavy)
    }

    static var topBarTitle: Font {
        isNative ? .system(size: 17, weight: .bold) : Font.custom(displayFamily, size: 18).weight(.heavy)
    }

    // UI — everything else
    static var cardTitle: Font { Catalog(scale: 1).title }
    static var countMeta: Font { // "3,781 casks" in top bar
        isNative ? .system(size: 12.5) : Font.custom(uiFamily, size: 11.5).weight(.semibold)
    }

    static var field: Font { // search field
        isNative ? .system(size: 13) : Font.custom(uiFamily, size: 12.5).weight(.semibold)
    }

    static var navItem: Font { Catalog(scale: 1).navigation }
    static var navActive: Font { Catalog(scale: 1).navigationActive }
    static var bodySm: Font { Catalog(scale: 1).description }
    static var body: Font { Catalog(scale: 1).body }
    static var button: Font {
        isNative ? .system(size: 12.5, weight: .semibold) : Font.custom(uiFamily, size: 12).weight(.heavy)
    }

    static var downloadLabel: Font {
        isNative ? .system(size: 10, weight: .semibold) : Font.custom(uiFamily, size: 10).weight(.semibold)
    }

    static var downloadProgress: Font {
        isNative ? .system(size: 9, weight: .semibold) : Font.custom(uiFamily, size: 9).weight(.semibold)
    }

    static var label: Font { Catalog(scale: 1).label } // + .kerning(trackingLabel), uppercase
    static var labelSm: Font { // row eyebrow
        isNative ? .system(size: 9.5, weight: .semibold) : Font.custom(uiFamily, size: 9).weight(.heavy)
    }

    // Mono — versions, counts, keycaps, status bar
    static var statusMono: Font { Catalog(scale: 1).status }

    static var trackingLabel: CGFloat { isNative ? 0.9 : 2 }
    static var trackingEyebrow: CGFloat { isNative ? 1.4 : 2.2 }
}

/// Text sizing for the catalog and window chrome; display scaling remains controlled by macOS.
enum CatalogTextSize: String, CaseIterable {
    case standard, larger, largest

    var scale: CGFloat {
        switch self {
        case .standard: 1
        case .larger: 1.1
        case .largest: 1.2
        }
    }
}

extension EnvironmentValues {
    @Entry var catalogTextScale: CGFloat = 1
}

extension CHType {
    struct Catalog {
        let scale: CGFloat

        var wordmark: Font { .custom(displayFamily, size: 19 * scale).weight(.heavy) }
        var keycap: Font { .custom(monoFamily, size: 9.5 * scale).weight(.bold) }
        var navigation: Font {
            isNative ? .system(size: 13 * scale) : .custom(uiFamily, size: 13 * scale).weight(.semibold)
        }

        var navigationActive: Font {
            isNative ? .system(size: 13 * scale, weight: .semibold) : .custom(uiFamily, size: 13 * scale).weight(.heavy)
        }

        var label: Font {
            isNative ? .system(size: 10.5 * scale, weight: .semibold) : .custom(uiFamily, size: 10 * scale).weight(.heavy)
        }

        var title: Font {
            isNative ? .system(size: 13.5 * scale, weight: .semibold) : .custom(uiFamily, size: 13 * scale).weight(.heavy)
        }

        var tag: Font {
            isNative ? .system(size: 11 * scale, weight: .medium) : .custom(uiFamily, size: 10 * scale).weight(.bold)
        }

        var description: Font {
            isNative ? .system(size: 11.5 * scale) : .custom(uiFamily, size: 11 * scale).weight(.semibold)
        }

        var body: Font {
            isNative ? .system(size: 13 * scale) : .custom(uiFamily, size: 13 * scale).weight(.semibold)
        }

        var meta: Font { .custom(monoFamily, size: 9.5 * scale) }
        var status: Font { .custom(monoFamily, size: 10.5 * scale) }
        var hero: Font {
            isNative ? .system(size: 28 * scale, weight: .bold) : .custom(displayFamily, size: 28 * scale).weight(.heavy)
        }
    }
}
