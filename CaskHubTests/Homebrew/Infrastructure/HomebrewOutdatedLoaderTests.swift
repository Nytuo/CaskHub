//
//  HomebrewOutdatedLoaderTests.swift
//  CaskHubTests
//
//  Created by Ali Elsokary on 05/10/2026.
//

@testable import CaskHub
import XCTest

final class HomebrewOutdatedLoaderTests: XCTestCase {
    func test_report_separates_pinned_casks_and_rejects_unparseable_output() {
        let output = #"{"formulae":[],"casks":[{"name":"brewy","pinned":false},{"name":"vlc","pinned":true},{"name":"old"}]}"#
        XCTAssertEqual(
            HomebrewOutdatedLoader.report(in: output),
            HomebrewOutdatedReport(upgradable: ["brewy", "old"], pinned: ["vlc"])
        )
        XCTAssertEqual(
            HomebrewOutdatedLoader.report(in: #"{"formulae":[],"casks":[]}"#),
            HomebrewOutdatedReport(upgradable: [], pinned: [])
        )
        XCTAssertNil(HomebrewOutdatedLoader.report(in: "Error: brew is broken"))
    }
}
