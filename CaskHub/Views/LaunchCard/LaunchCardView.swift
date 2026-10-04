//
//  LaunchCardView.swift
//  CaskHub
//
//  Created by Ali Elsokary on 04/10/2026.
//

import SwiftUI

struct LaunchCardView: View {
    let card: LaunchCard

    var body: some View {
        Group {
            switch card {
            case .welcome:
                WelcomeCardView()
            case let .whatsNew(release):
                WhatsNewCardView(release: release)
            }
        }
        .background(Color.chSurfaceHero)
        .onAppear { Analytics.launchCardShown(card) }
    }
}

struct LaunchCardButton: View {
    let title: LocalizedStringResource
    let isProminent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CHType.cardTitle)
                .foregroundStyle(isProminent ? Color.white : Color.chTextNav)
                .padding(.horizontal, 15)
                .frame(height: 36)
                .background(Capsule().fill(isProminent ? Color.chAccent : Color.chSurfaceField))
                .overlay(Capsule().strokeBorder(isProminent ? Color.clear : Color.chHairlineStrong, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
