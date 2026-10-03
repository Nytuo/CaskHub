//
//  TopBarView.swift
//  CaskHub
//
//  Created by Ali Elsokary on 08/07/2026.
//

import SwiftUI

/// Page title and count, inline on the window toolbar's leading edge.
struct TopBarTitle: ToolbarContent {
    let title: String
    var summary: String?

    var body: some ToolbarContent {
        if #available(macOS 26, *) {
            item.sharedBackgroundVisibility(.hidden)
        } else {
            item
        }
    }

    private var item: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(CHType.topBarTitle)
                    .foregroundStyle(Color.chTextTitle)
                if let summary {
                    Text(summary)
                        .font(CHType.countMeta)
                        .foregroundStyle(CHType.isNative ? Color.chTextBody : Color.chTextMuted)
                }
            }
            .lineLimit(1)
            .fixedSize()
            .padding(.leading, 4)
            // Toolbar items keep their first measured width; a new identity per page re-measures it.
            .id(title)
        }
    }
}

/// Catalog filters and view mode as system toolbar items; search is attached with `.searchable`.
struct CatalogToolbar: ToolbarContent {
    @Binding var sortOption: SortOption
    var sortOptions: [SortOption] = SortOption.standard
    @Binding var viewMode: ViewMode
    var analyticsPeriod: AnalyticsPeriod?
    var onSelectPeriod: ((AnalyticsPeriod) -> Void)?
    var recentWindow: RecentlyAddedWindow?
    var onSelectWindow: ((RecentlyAddedWindow) -> Void)?
    var onUpdateAll: (() -> Void)?
    var updateAllCount = 0
    var isUpdatingAll: Bool
    var isUpdatingHomebrew: Bool
    var greedyUpdates: Bool?
    var onToggleGreedy: ((Bool) -> Void)?
    var showsSort = true

    var body: some ToolbarContent {
        if #available(macOS 26, *) {
            ToolbarSpacer(.flexible)
        }
        if let greedyUpdates {
            ToolbarItem(placement: .automatic) {
                Toggle(isOn: Binding(get: { greedyUpdates }, set: { onToggleGreedy?($0) })) {
                    Label("Greedy", systemImage: greedyUpdates ? "checkmark.circle.fill" : "circle")
                        .labelStyle(.titleAndIcon)
                }
                .toggleStyle(.button)
                .help("Also list apps that update themselves (brew upgrade --greedy)")
            }
        }
        if greedyUpdates != nil, onUpdateAll != nil, #available(macOS 26, *) {
            // Keeps Greedy in its own glass capsule instead of merging with Update All.
            ToolbarSpacer(.fixed)
        }
        if let onUpdateAll {
            ToolbarItem(placement: .automatic) {
                UpdateAllButton(
                    count: updateAllCount,
                    isUpdatingAll: isUpdatingAll,
                    isUpdatingHomebrew: isUpdatingHomebrew,
                    onUpdateAll: onUpdateAll
                )
            }
        }
        if showsSort {
            ToolbarItem(placement: .automatic) {
                OptionMenu(current: sortOption, options: sortOptions, label: \.title, systemImage: "arrow.up.arrow.down") {
                    if $0 != sortOption { Analytics.sortChanged($0) }
                    sortOption = $0
                }
            }
        }
        if let analyticsPeriod {
            ToolbarItem(placement: .automatic) {
                OptionMenu(current: analyticsPeriod, options: AnalyticsPeriod.allCases, label: \.label, systemImage: "clock") {
                    onSelectPeriod?($0)
                }
            }
        }
        if let recentWindow {
            ToolbarItem(placement: .automatic) {
                OptionMenu(current: recentWindow, options: RecentlyAddedWindow.allCases, label: \.label, systemImage: "clock") {
                    onSelectWindow?($0)
                }
            }
        }
        ToolbarItem(placement: .automatic) {
            Picker("View Mode", selection: $viewMode) {
                Label("Grid", systemImage: "square.grid.2x2").tag(ViewMode.grid)
                Label("List", systemImage: "list.bullet").tag(ViewMode.list)
            }
            .pickerStyle(.segmented)
            .labelStyle(.iconOnly)
        }
    }
}

/// Toolbar menu that shows the current choice and checks it in the list.
private struct OptionMenu<Option: Identifiable & Equatable>: View {
    let current: Option
    let options: [Option]
    let label: KeyPath<Option, String>
    let systemImage: String
    let onSelect: (Option) -> Void

    var body: some View {
        Menu {
            ForEach(options) { option in
                Toggle(option[keyPath: label], isOn: Binding(get: { option == current }, set: { _ in onSelect(option) }))
            }
        } label: {
            Label(current[keyPath: label], systemImage: systemImage)
                .labelStyle(.titleAndIcon)
        }
        // Toolbar items keep their first measured width; a new identity per choice re-measures it.
        .fixedSize()
        .id(current.id)
    }
}

private struct UpdateAllButton: View {
    let count: Int
    let isUpdatingAll: Bool
    let isUpdatingHomebrew: Bool
    let onUpdateAll: () -> Void

    @State private var showsConfirmation = false

    var body: some View {
        Button {
            showsConfirmation = true
        } label: {
            if isUpdatingAll {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Updating…")
                }
            } else {
                Label("Update All", systemImage: CaskActionStyle.update.icon)
                    .labelStyle(.titleAndIcon)
            }
        }
        .disabled(isUpdatingAll || isUpdatingHomebrew)
        .help(
            isUpdatingHomebrew
                ? String(localized: "Wait for the current action to finish.")
                : String(localized: "Update All")
        )
        .alert("Update All Apps?", isPresented: $showsConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Update All", action: onUpdateAll)
        } message: {
            Text(.alertUpdateAllConfirmation(count))
        }
    }
}
