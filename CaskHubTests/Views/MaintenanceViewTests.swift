//
//  MaintenanceViewTests.swift
//  CaskHubTests
//
//  Created by Ali Elsokary on 19/08/2026.
//

@testable import CaskHub
import SwiftUI
import XCTest

final class MaintenanceViewTests: XCTestCase {
    @MainActor
    func test_health_and_shelf_pills_match_card_height_in_both_styles() {
        let originalStyle = AppStyle.current
        defer { AppStyle.current = originalStyle }
        let probe = CGSize(width: 400, height: 100)
        for style in AppStyle.allCases {
            AppStyle.current = style
            let heights = [
                NSHostingController(rootView: ActionCapsuleButton(action: .open) {})
                    .sizeThatFits(in: probe).height,
                NSHostingController(rootView: ActionCapsuleButton(action: .update, fullWidth: false) {})
                    .sizeThatFits(in: probe).height,
                NSHostingController(rootView: PillButton(
                    title: "Sync now", background: .chActionInstallBg, border: .chActionInstallBorder,
                    foreground: .chActionInstallFg
                ) {}).sizeThatFits(in: probe).height,
                NSHostingController(rootView: PillButton(
                    title: "Clean", background: .chActionUpdateBg, border: .chActionUpdateBorder,
                    foreground: .chActionUpdateFg
                ) {}.frame(minWidth: 74)).sizeThatFits(in: probe).height,
                NSHostingController(rootView: StatusPill(title: "Up to date")).sizeThatFits(in: probe).height,
                NSHostingController(rootView: WorkingPill(title: "Working")).sizeThatFits(in: probe).height
            ]
            XCTAssertEqual(Set(heights), [CHSize.actionCapsuleHeight], "\(style) \(heights)")
        }
    }

    @MainActor
    func test_page_renders_before_first_checkup() {
        render(MaintenanceView(model: makeMaintenanceModel()).environment(ImageCacheService()))
    }

    @MainActor
    func test_disk_card_renders_loading_state_before_first_scan() {
        render(MaintenanceDiskCard(model: makeMaintenanceModel()))
    }

    @MainActor
    func test_page_renders_checkup_results() async {
        let probe = RecordingMaintenanceProbe()
        probe.resultsByFirstArgument = [
            "-p": BrewProbeResult(exitCode: 0, output: "/Library/Developer/CommandLineTools\n"),
            "doctor": BrewProbeResult(exitCode: 1, output: """
            Warning: Broken symlinks were found. Remove them with `brew cleanup`:
              /opt/homebrew/lib/libfoo.dylib
            """)
        ]
        let model = makeMaintenanceModel(probe: probe)
        await model.runCheckup()

        render(MaintenanceView(model: model).environment(ImageCacheService()))
    }

    @MainActor
    func test_disk_card_renders_sizes_and_expanded_rows() async {
        let probe = RecordingMaintenanceProbe()
        probe.resultsByFirstArgument = [
            "cleanup": BrewProbeResult(exitCode: 0, output: """
            Would remove: /opt/homebrew/Caskroom/figma/124.7 (3 files, 200MB)
            """),
            "autoremove": BrewProbeResult(exitCode: 0, output: """
            ==> Would autoremove 1 unneeded formulae:
            libyaml
            """)
        ]
        probe.directorySizes = ["Homebrew": 1_000, "icons": 2_000, "libyaml": 300]
        let model = makeMaintenanceModel(probe: probe)
        await model.refreshDisk()
        model.expandedRows = [.cache, .imageCache]

        render(MaintenanceDiskCard(model: model))
    }

    @MainActor
    func test_disk_card_renders_done_and_failed_rows() async {
        let probe = RecordingMaintenanceProbe()
        probe.resultsByFirstArgument = [
            "autoremove": BrewProbeResult(exitCode: 1, output: "Error: nope")
        ]
        let model = makeMaintenanceModel(probe: probe)
        await model.clean(.imageCache)
        await model.clean(.orphans)

        render(MaintenanceDiskCard(model: model))
    }
}
