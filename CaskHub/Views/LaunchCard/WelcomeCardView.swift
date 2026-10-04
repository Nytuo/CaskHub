//
//  WelcomeCardView.swift
//  CaskHub
//
//  Created by Ali Elsokary on 04/10/2026.
//

import SwiftUI

enum WelcomePage: Int, CaseIterable {
    case intro, icons, categories, recentlyAdded, manage, adopt, look, privacy, ready

    var symbol: String? {
        switch self {
        case .intro: nil
        case .icons: "sparkles.square.filled.on.square"
        case .categories: DiscoverItem.browse.icon
        case .recentlyAdded: DiscoverItem.recentlyAdded.icon
        case .manage: LibraryItem.updates.icon
        case .adopt: LibraryItem.adopt.icon
        case .look: "paintbrush"
        case .privacy: "hand.raised"
        case .ready: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .intro, .manage: .chTerracotta
        case .icons, .privacy: .chAmber
        case .categories, .adopt, .ready: .chSage
        case .recentlyAdded, .look: .chPlum
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .intro: .launchCardWelcomeIntroTitle
        case .icons: .launchCardWelcomeIconsTitle
        case .categories: .launchCardWelcomeCategoriesTitle
        case .recentlyAdded: .launchCardWelcomeRecentlyAddedTitle
        case .manage: .launchCardWelcomeManageTitle
        case .adopt: .launchCardWelcomeAdoptTitle
        case .look: .launchCardWelcomeLookTitle
        case .privacy: .launchCardWelcomePrivacyTitle
        case .ready: .launchCardWelcomeReadyTitle
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .intro: .launchCardWelcomeIntroDetail
        case .icons: .launchCardWelcomeIconsDetail
        case .categories: .launchCardWelcomeCategoriesDetail
        case .recentlyAdded: .launchCardWelcomeRecentlyAddedDetail
        case .manage: .launchCardWelcomeManageDetail
        case .adopt: .launchCardWelcomeAdoptDetail
        case .look: .launchCardWelcomeLookDetail
        case .privacy: .launchCardWelcomePrivacyDetail
        case .ready: .launchCardWelcomeReadyDetail
        }
    }
}

struct WelcomeCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page: WelcomePage

    init(page: WelcomePage = .intro) {
        _page = State(initialValue: page)
    }

    private var isLastPage: Bool {
        page == WelcomePage.allCases.last
    }

    var body: some View {
        VStack(spacing: 0) {
            ViewThatFits(in: .vertical) {
                content.frame(maxHeight: .infinity)
                ScrollView { content }
            }
            footer
        }
        .frame(width: 600, height: 480)
        .onDisappear { Analytics.launchCardDismissed(.welcome, page: page.rawValue + 1) }
    }

    private var content: some View {
        VStack(spacing: 14) {
            hero
            Text(page.title)
                .font(CHType.Catalog(scale: 0.8).hero)
                .foregroundStyle(Color.chTextTitle)
            Text(page.detail)
                .font(CHType.body)
                .foregroundStyle(Color.chTextBody)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
                .fixedSize(horizontal: false, vertical: true)
            accessory
                .padding(.top, 6)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .id(page)
        .transition(.opacity)
    }

    @ViewBuilder private var hero: some View {
        if let symbol = page.symbol {
            Image(systemName: symbol)
                .font(.system(size: 52))
                .foregroundStyle(page.tint)
                .frame(height: 64)
                .accessibilityHidden(true)
        } else {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder private var accessory: some View {
        switch page {
        case .look:
            AppStylePicker()
        case .privacy:
            WelcomePrivacyToggles()
        case .ready:
            VStack(alignment: .leading, spacing: 10) {
                WelcomeShortcutRow(keys: ["⌘F"], label: .launchCardWelcomeShortcutSearch)
                WelcomeShortcutRow(keys: ["⌘1", "⌘2"], label: .launchCardWelcomeShortcutViewMode)
                WelcomeShortcutRow(keys: ["⌘,"], label: .launchCardWelcomeShortcutSettings)
            }
        default:
            EmptyView()
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            if !isLastPage {
                Button(String(localized: .launchCardButtonSkip)) {
                    dismiss()
                }
                .buttonStyle(.plain)
                .font(CHType.button)
                .foregroundStyle(Color.chTextMuted)
            }
            Spacer()
            if page != .intro {
                LaunchCardButton(title: .launchCardButtonBack, isProminent: false) {
                    move(by: -1)
                }
            }
            LaunchCardButton(
                title: isLastPage ? .launchCardButtonGetStarted : .launchCardButtonNext,
                isProminent: true
            ) {
                if isLastPage {
                    dismiss()
                } else {
                    move(by: 1)
                }
            }
            .keyboardShortcut(.defaultAction)
        }
        .overlay { pageDots }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .overlay(alignment: .top) { Color.chHairline.frame(height: 1) }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(WelcomePage.allCases, id: \.self) { item in
                Circle()
                    .fill(item == page ? Color.chAccent : Color.chTextFaint.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text(.launchCardWelcomePageIndicator(page.rawValue + 1, WelcomePage.allCases.count)))
    }

    private func move(by offset: Int) {
        guard let next = WelcomePage(rawValue: page.rawValue + offset) else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            page = next
        }
    }
}

private struct WelcomePrivacyToggles: View {
    @AppStorage(Analytics.enabledKey) private var analyticsEnabled = true
    @AppStorage(CrashReporter.enabledKey) private var crashReportingEnabled = true

    var body: some View {
        VStack(spacing: 10) {
            toggle("Share anonymous usage analytics", isOn: $analyticsEnabled)
            Color.chHairline.frame(height: 1)
            toggle("Share crash reports", isOn: $crashReportingEnabled)
        }
        .toggleStyle(.switch)
        .tint(Color.chAccent)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: CHRadius.card).fill(Color.chSurfaceField))
        .overlay(RoundedRectangle(cornerRadius: CHRadius.card).strokeBorder(Color.chHairline, lineWidth: 1))
        .frame(maxWidth: 380)
        .applyingPrivacyChanges(analytics: analyticsEnabled, crashReports: crashReportingEnabled)
    }

    private func toggle(_ title: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(CHType.body)
                .foregroundStyle(Color.chTextTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct WelcomeShortcutRow: View {
    let keys: [String]
    let label: LocalizedStringResource

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(keys, id: \.self) { Keycap(symbol: $0) }
            }
            .frame(width: 64, alignment: .trailing)
            Text(label)
                .font(CHType.body)
                .foregroundStyle(Color.chTextBody)
        }
        .accessibilityElement(children: .combine)
    }
}
