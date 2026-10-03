//
//  GlassPanel.swift
//  CaskHub
//
//  Created by Ali Elsokary on 07/07/2026.
//

import SwiftUI

private struct GlassPanelModifier: ViewModifier {
    var radius: CGFloat
    var surface: Color
    var shadow: Color

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        if CHType.isNative {
            content.background { NativeCardSurface(shape: shape, fill: surface) }
        } else {
            classic(content, shape: shape)
        }
    }

    private func classic(_ content: Content, shape: RoundedRectangle) -> some View {
        content
            .background {
                shape
                    .fill(surface)
                    .background(.ultraThinMaterial, in: shape)
                    .overlay {
                        shape.strokeBorder(
                            LinearGradient(
                                colors: [Color.chHairlineStrong, Color.chHairline.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                    }
                    .shadow(color: shadow, radius: 11, y: 4)
            }
    }
}

/// Native card: solid fill, bright top edge, hairline outer edge; depth without blurred shadows.
private struct NativeCardSurface: View {
    let shape: RoundedRectangle
    let fill: Color

    var body: some View {
        shape
            .fill(fill)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [Color.chNativeCardHighlight, .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.08)
                    ),
                    lineWidth: 1
                )
            }
            .overlay { shape.stroke(Color.chNativeCardEdge, lineWidth: 0.5) }
            .shadow(color: Color.chNativeCardShadow, radius: 1.5, y: 1)
    }
}

/// Toolbar controls: Classic tinted capsule with hairline; Native Liquid Glass (solid before macOS 26).
private struct ToolbarCapsuleModifier: ViewModifier {
    var fill: Color
    var border: Color
    var isNeutral: Bool

    func body(content: Content) -> some View {
        if CHType.isNative, isNeutral {
            if #available(macOS 26, *) {
                content.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                content
                    .background(Capsule().fill(Color.chSurfaceToolbar))
                    .overlay(Capsule().stroke(Color.chNativeCardEdge, lineWidth: 0.5))
            }
        } else {
            content
                .background(Capsule().fill(fill))
                .overlay(Capsule().strokeBorder(border, lineWidth: 1))
        }
    }
}

extension View {
    func toolbarCapsule(
        fill: Color = .chSurfaceField,
        border: Color = .chHairlineStrong,
        isNeutral: Bool = true
    ) -> some View {
        modifier(ToolbarCapsuleModifier(fill: fill, border: border, isNeutral: isNeutral))
    }

    /// Lets neighbouring Native glass capsules sample and blend with each other.
    @ViewBuilder
    func toolbarGlassGroup(spacing: CGFloat) -> some View {
        if #available(macOS 26, *), CHType.isNative {
            GlassEffectContainer(spacing: spacing) { self }
        } else {
            self
        }
    }

    /// Classic floats a top bar in a frosted panel; Native leaves it on the window like a toolbar.
    @ViewBuilder
    func toolbarChrome(classicInsets: EdgeInsets, radius: CGFloat) -> some View {
        if CHType.isNative {
            frame(minHeight: 30).padding(.vertical, 4)
        } else {
            padding(classicInsets).glassPanel(radius: radius, surface: .chSurfaceToolbar)
        }
    }

    func glassPanel(
        radius: CGFloat = CHRadius.card,
        surface: Color = .chSurfaceCard,
        shadow: Color = .chShadowCard
    ) -> some View {
        modifier(GlassPanelModifier(radius: radius, surface: surface, shadow: shadow))
    }
}

struct WindowBackdrop: View {
    var body: some View {
        if CHType.isNative {
            Color.chNativeWindow.ignoresSafeArea()
        } else {
            classic
        }
    }

    private var classic: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: .chBg1, location: 0),
                        .init(color: .chBg2, location: 0.55),
                        .init(color: .chBg3, location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                blob(.chBlobTerracotta, diameter: 460)
                    .position(x: 150, y: 330)
                blob(.chBlobAmber, diameter: 420)
                    .position(x: geo.size.width - 150, y: 130)
                blob(.chBlobSage, diameter: 480)
                    .position(x: geo.size.width - 500, y: geo.size.height - 120)
                HalftoneTexture()
            }
        }
        .ignoresSafeArea()
    }

    private func blob(_ color: Color, diameter: CGFloat) -> some View {
        RadialGradient(colors: [color, .clear], center: .center, startRadius: 0, endRadius: diameter / 2)
            .frame(width: diameter, height: diameter)
    }
}

struct HalftoneTexture: View {
    var body: some View {
        // ponytail: O(w·h/81) dots per redraw; switch to a tiled image if resize ever stutters
        Canvas { ctx, size in
            let step: CGFloat = 9
            var dotY: CGFloat = 4
            while dotY < size.height {
                var dotX: CGFloat = 4
                while dotX < size.width {
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: dotX, y: dotY, width: 2, height: 2)),
                        with: .color(.chHalftoneDot)
                    )
                    dotX += step
                }
                dotY += step
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        WindowBackdrop()
        Text("Frosted panel")
            .font(CHType.cardTitle)
            .foregroundStyle(Color.chTextTitle)
            .padding(24)
            .glassPanel()
    }
    .frame(width: 600, height: 400)
}
