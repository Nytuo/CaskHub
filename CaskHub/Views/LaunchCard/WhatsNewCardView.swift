//
//  WhatsNewCardView.swift
//  CaskHub
//
//  Created by Ali Elsokary on 04/10/2026.
//

import SwiftUI

/// Metrics measured from Apple's own What's New sheets (Voice Memos, Stocks) on macOS 26.
struct WhatsNewCardView: View {
    let release: WhatsNewRelease
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(.launchCardWhatsNewTitle)
                .font(CHType.Catalog(scale: 0.72).hero)
                .foregroundStyle(Color.chTextTitle)
                .padding(.top, 52)
                .padding(.bottom, 48)
            VStack(alignment: .leading, spacing: 17) {
                ForEach(release.features, id: \.symbol) { feature in
                    WhatsNewFeatureRow(feature: feature)
                }
            }
            Spacer(minLength: 24)
            HStack {
                Spacer()
                LaunchCardButton(title: .launchCardButtonContinue, isProminent: true) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.leading, 60)
        .padding(.trailing, 20)
        .padding(.bottom, 36)
        .frame(width: 480, height: 600)
        .onDisappear { Analytics.launchCardDismissed(.whatsNew) }
    }
}

private struct WhatsNewFeatureRow: View {
    let feature: WhatsNewRelease.Feature

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: feature.symbol)
                .font(.system(size: 28))
                .foregroundStyle(Color.chAccent)
                .frame(width: 48, height: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(CHType.cardTitle)
                    .foregroundStyle(Color.chTextTitle)
                Text(feature.detail)
                    .font(CHType.body)
                    .lineSpacing(2)
                    .foregroundStyle(Color.chTextBody)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 276, alignment: .leading)
        }
        .frame(minHeight: 44, alignment: .top)
        .accessibilityElement(children: .combine)
    }
}
