//
//  ColorTokens.swift
//  CaskHub
//
//  Created by Ali Elsokary on 07/07/2026.
//

import SwiftUI

private extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

private func adaptive(light: NSColor, dark: NSColor) -> Color {
    Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
    })
}

private func adaptive(_ light: UInt32, _ dark: UInt32, alpha: (light: CGFloat, dark: CGFloat) = (1, 1)) -> Color {
    adaptive(light: NSColor(hex: light, alpha: alpha.light), dark: NSColor(hex: dark, alpha: alpha.dark))
}

private func styled(_ classic: Color, _ native: Color) -> Color {
    AppStyle.current == .native ? native : classic
}

extension Color {
    // ── Base palette (fixed) ──────────────────────────
    static let chCream = Color(nsColor: NSColor(hex: 0xF6E9CB))
    static let chInk = Color(nsColor: NSColor(hex: 0x33304A))
    static let chTerracotta = Color(nsColor: NSColor(hex: 0xC8674A))
    static let chTerracottaLid = Color(nsColor: NSColor(hex: 0xA94F36))
    static let chGoldBand = Color(nsColor: NSColor(hex: 0xF0D59A))
    static let chSage = Color(nsColor: NSColor(hex: 0x6FA287))
    static let chAmber = Color(nsColor: NSColor(hex: 0xD99A4E))
    static let chPlum = Color(nsColor: NSColor(hex: 0x8D87A0))

    // ── Window background gradient stops (Classic backdrop) ──
    static let chBg1 = adaptive(light: NSColor(hex: 0xF2E2BD), dark: NSColor(hex: 0x232030))
    static let chBg2 = adaptive(light: NSColor(hex: 0xF8EED8), dark: NSColor(hex: 0x2E2A40))
    static let chBg3 = adaptive(light: NSColor(hex: 0xF3E6C6), dark: NSColor(hex: 0x262234))

    // ── Glass surfaces ─────────────────────────────────
    static var chSurfaceToolbar: Color { styled(Classic.surfaceToolbar, Native.glass) }
    static var chSurfaceCard: Color { styled(Classic.surfaceCard, Native.card) }
    static var chSurfaceHero: Color { styled(Classic.surfaceHero, Native.card) }
    static var chSurfaceStatusbar: Color { styled(Classic.surfaceStatusbar, Native.window) }
    static var chSurfaceField: Color { styled(Classic.surfaceField, Native.field) }
    static var chSurfaceWell: Color { styled(Classic.surfaceField, Native.well) }
    static var chSurfaceTerminal: Color { styled(chInk, Native.terminal) }
    static var chSurfaceKeycap: Color { styled(Classic.surfaceKeycap, Native.keycap) }

    // ── Hairlines & separators ─────────────────────────
    static var chHairline: Color { styled(Classic.hairline, Native.separator) }
    static var chHairlineStrong: Color { styled(Classic.hairlineStrong, .clear) }
    static var chEdge: Color { styled(Classic.hairlineStrong, Native.separator) }
    static var chScrim: Color { styled(chInk.opacity(0.50), Native.scrim) }

    // ── Text ───────────────────────────────────────────
    static var chTextTitle: Color { styled(Classic.textTitle, Native.textPrimary) }
    static var chTextBody: Color { styled(Classic.textBody, Native.textSecondary) }
    static var chTextNav: Color { styled(Classic.textNav, Native.textPrimary) }
    static var chTextMuted: Color { styled(Classic.textMuted, Native.textTertiary) }
    static var chTextFaint: Color { styled(Classic.textFaint, Native.textTertiary) }
    static var chTextBrand: Color { styled(Classic.textBrand, Native.accent) }
    static var chAccent: Color { styled(chTerracotta, Native.accent) }

    // ── Action colors (tonal liquid-glass capsules) ────
    static var chActionInstallBg: Color { styled(Classic.actionInstallBg, Native.actionInstallBg) }
    static var chActionInstallBorder: Color { styled(Classic.actionInstallBorder, .clear) }
    static var chActionInstallFg: Color { styled(Classic.actionInstallFg, Native.actionInstallFg) }
    static var chActionUpdateBg: Color { styled(Classic.actionUpdateBg, Native.actionUpdateBg) }
    static var chActionUpdateBorder: Color { styled(Classic.actionUpdateBorder, .clear) }
    static var chActionUpdateFg: Color { styled(Classic.actionUpdateFg, Native.actionUpdateFg) }
    static var chActionDoneBg: Color { styled(Classic.actionDoneBg, Native.actionDoneBg) }
    static var chActionDoneBorder: Color { styled(Classic.actionDoneBorder, .clear) }
    static var chActionDoneFg: Color { styled(Classic.actionDoneFg, Native.actionDoneFg) }

    // ── Selection (sidebar rows, menu rows) ────────────
    static var chSelectionBg: Color { styled(Classic.actionInstallBg, Native.selectionBg) }
    static var chSelectionFg: Color { styled(Classic.actionInstallFg, Native.selectionFg) }

    /// ── Segmented view-mode toggle ─────────────────────
    /// Classic: ink capsule + cream glyph in light; cream capsule + ink glyph in dark.
    /// Native: faint neutral capsule + accent glyph.
    static var chSegmentIcon: Color { styled(Classic.segmentIcon, Native.accent) }
    static var chSegmentSelected: Color { styled(Classic.textTitle, Native.segmentSelected) }

    // ── Badge ──────────────────────────────────────────
    static var chBadgeBg: Color { styled(Classic.badgeBg, Native.badgeBg) }
    static var chBadgeBorder: Color { styled(Classic.badgeBorder, .clear) }
    static var chBadgeFg: Color { styled(Classic.badgeFg, Native.badgeFg) }

    // ── Decorative blob glows (Classic backdrop) ───────
    static let chBlobTerracotta = adaptive(light: NSColor(hex: 0xC8674A, alpha: 0.38), dark: NSColor(hex: 0xC8674A, alpha: 0.35))
    static let chBlobAmber = adaptive(light: NSColor(hex: 0xD99A4E, alpha: 0.40), dark: NSColor(hex: 0xD99A4E, alpha: 0.28))
    static let chBlobSage = adaptive(light: NSColor(hex: 0x6FA287, alpha: 0.35), dark: NSColor(hex: 0x6FA287, alpha: 0.26))

    // ── Textures & shadows ─────────────────────────────
    static let chHalftoneDot = adaptive(light: NSColor(hex: 0x33304A, alpha: 0.05), dark: NSColor(hex: 0xF6E9CB, alpha: 0.045))
    static var chShadowCard: Color { styled(Classic.shadowCard, .clear) }
    static var chShadowHero: Color { styled(Classic.shadowHero, .clear) }

    /// ── Barrel mark ────────────────────────────────────
    static let chBarrelOutline = chInk

    // ── Native-only chrome ─────────────────────────────
    static let chNativeWindow = Native.window
    static let chNativeSidebar = Native.sidebar
    static let chNativeCardHighlight = Native.cardHighlight
    static let chNativeCardEdge = Native.cardEdge
    static let chNativeCardShadow = Native.cardShadow
}

private enum Classic {
    static let surfaceToolbar = adaptive(light: NSColor(hex: 0xFDF6E4, alpha: 0.82), dark: NSColor(hex: 0x353147, alpha: 0.85))
    static let surfaceCard = adaptive(light: NSColor(hex: 0xFDF6E4, alpha: 0.80), dark: NSColor(hex: 0x353147, alpha: 0.85))
    static let surfaceHero = adaptive(light: NSColor(hex: 0xFDF6E4, alpha: 0.78), dark: NSColor(hex: 0x3A3450, alpha: 0.85))
    static let surfaceStatusbar = adaptive(light: NSColor(hex: 0xEFDCB2, alpha: 0.85), dark: NSColor(hex: 0x242132, alpha: 0.90))
    static let surfaceField = adaptive(light: NSColor(hex: 0xFFFFFF, alpha: 0.50), dark: NSColor(hex: 0xFFFFFF, alpha: 0.08))
    static let surfaceKeycap = adaptive(light: NSColor(hex: 0xFFFFFF, alpha: 0.55), dark: NSColor(hex: 0xFFFFFF, alpha: 0.12))

    static let hairline = adaptive(light: NSColor(hex: 0xFFFFFF, alpha: 0.75), dark: NSColor(hex: 0xFFFFFF, alpha: 0.14))
    static let hairlineStrong = adaptive(light: NSColor(hex: 0xFFFFFF, alpha: 0.90), dark: NSColor(hex: 0xFFFFFF, alpha: 0.22))

    static let textTitle = adaptive(light: NSColor(hex: 0x33304A), dark: NSColor(hex: 0xF6E9CB))
    static let textBody = adaptive(light: NSColor(hex: 0x6B6252), dark: NSColor(hex: 0xB3ACC5))
    static let textNav = adaptive(light: NSColor(hex: 0x5A5344), dark: NSColor(hex: 0xC5BFD4))
    static let textMuted = adaptive(light: NSColor(hex: 0xA08D63), dark: NSColor(hex: 0x8D87A0))
    static let textFaint = adaptive(light: NSColor(hex: 0xB3A074), dark: NSColor(hex: 0x6A6380))
    static let textBrand = adaptive(light: NSColor(hex: 0xC8674A), dark: NSColor(hex: 0xE0876A))

    static let actionInstallBg = adaptive(light: NSColor(hex: 0xC8674A, alpha: 0.22), dark: NSColor(hex: 0xE0876A, alpha: 0.16))
    static let actionInstallBorder = adaptive(light: NSColor(hex: 0xC8674A, alpha: 0.55), dark: NSColor(hex: 0xE0876A, alpha: 0.45))
    static let actionInstallFg = adaptive(light: NSColor(hex: 0x9C4A2B), dark: NSColor(hex: 0xF0A284))
    static let actionUpdateBg = adaptive(light: NSColor(hex: 0xD99A4E, alpha: 0.28), dark: NSColor(hex: 0xE2AB60, alpha: 0.18))
    static let actionUpdateBorder = adaptive(light: NSColor(hex: 0xD99A4E, alpha: 0.60), dark: NSColor(hex: 0xE2AB60, alpha: 0.50))
    static let actionUpdateFg = adaptive(light: NSColor(hex: 0x8A5A1A), dark: NSColor(hex: 0xECC084))
    static let actionDoneBg = adaptive(light: NSColor(hex: 0x6FA287, alpha: 0.25), dark: NSColor(hex: 0x6FA287, alpha: 0.20))
    static let actionDoneBorder = adaptive(light: NSColor(hex: 0x6FA287, alpha: 0.60), dark: NSColor(hex: 0x6FA287, alpha: 0.50))
    static let actionDoneFg = adaptive(light: NSColor(hex: 0x3E6E55), dark: NSColor(hex: 0x8FC4A8))

    static let segmentIcon = adaptive(light: NSColor(hex: 0xFDF6E4), dark: NSColor(hex: 0x2B2838))

    static let badgeBg = adaptive(light: NSColor(hex: 0xD99A4E, alpha: 0.35), dark: NSColor(hex: 0xE2AB60, alpha: 0.28))
    static let badgeBorder = adaptive(light: NSColor(hex: 0xFFFFFF, alpha: 0.80), dark: NSColor(hex: 0xFFFFFF, alpha: 0.30))
    static let badgeFg = adaptive(light: NSColor(hex: 0x8A5A1A), dark: NSColor(hex: 0xECC084))

    static let shadowCard = adaptive(light: NSColor(hex: 0x33304A, alpha: 0.10), dark: NSColor(hex: 0x000000, alpha: 0.28))
    static let shadowHero = adaptive(light: NSColor(hex: 0x33304A, alpha: 0.12), dark: NSColor(hex: 0x000000, alpha: 0.35))
}

/// Design "1a Floating glass": light uses the 6a glass edge, dark the 5b Tahoe glass edge,
/// actions use 3d Richer tonal.
private enum Native {
    static let window = adaptive(0xF2F2F4, 0x1C1C1E)
    static let sidebar = adaptive(0xFBFBFC, 0x2C2C2E)
    static let card = adaptive(0xFDFDFE, 0x262628)
    static let cardHighlight = adaptive(0xFFFFFF, 0xFFFFFF, alpha: (1, 0.10))
    static let cardEdge = adaptive(0x000000, 0x000000, alpha: (0.10, 0.60))
    static let cardShadow = adaptive(0x000000, 0x000000, alpha: (0.05, 0))
    static let glass = adaptive(0xFDFDFE, 0x2C2C2E)
    static let well = adaptive(0xFFFFFF, 0x323234)
    static let field = adaptive(0x000000, 0xFFFFFF, alpha: (0.05, 0.07))
    static let keycap = adaptive(0x000000, 0xFFFFFF, alpha: (0.06, 0.08))
    static let terminal = adaptive(0x33304A, 0x38383C)
    static let separator = adaptive(0x000000, 0xFFFFFF, alpha: (0.08, 0.08))
    static let segmentSelected = adaptive(0x000000, 0xFFFFFF, alpha: (0.07, 0.13))
    static let scrim = adaptive(0xFDFDFE, 0x1C1C1E, alpha: (0.7, 0.6))

    static let textPrimary = adaptive(0x1D1D1F, 0xF5F5F7)
    static let textSecondary = adaptive(0x6E6E73, 0xA1A1A6)
    static let textTertiary = adaptive(0x8E8E93, 0x7D7D82)
    static let accent = adaptive(0xB4553A, 0xEC9575)

    static let actionInstallBg = adaptive(0xF6DDD3, 0xC46246, alpha: (1, 0.20))
    static let actionInstallFg = adaptive(0x9C4127, 0xF2AB8F)
    static let actionUpdateBg = adaptive(0xF8E6C8, 0xC88C42, alpha: (1, 0.20))
    static let actionUpdateFg = adaptive(0x83520F, 0xF0C68E)
    static let actionDoneBg = adaptive(0xD9EBDF, 0x689E80, alpha: (1, 0.17))
    static let actionDoneFg = adaptive(0x2F6448, 0x9FD6B7)

    static let selectionBg = adaptive(0xC8674A, 0xE8916F, alpha: (0.15, 0.20))
    static let selectionFg = adaptive(0xA5492D, 0xF4B49A)

    static let badgeBg = adaptive(0xD99A4E, 0xE8B26C, alpha: (0.22, 0.20))
    static let badgeFg = adaptive(0xB07624, 0xF0C68E)
}
