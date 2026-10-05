//
//  HomebrewOutdatedLoaderTests.swift
//  CaskHubTests
//
//  Created by Ali Elsokary on 05/10/2026.
//

@testable import CaskHub
import XCTest

final class HomebrewOutdatedLoaderTests: XCTestCase {
    func test_tokens_reads_cask_names_and_rejects_unparseable_output() {
        let output = #"{"formulae":[],"casks":[{"name":"brewy","installed_versions":["0.26.0"],"current_version":"0.26.2"}]}"#
        XCTAssertEqual(HomebrewOutdatedLoader.tokens(in: output), ["brewy"])
        XCTAssertEqual(HomebrewOutdatedLoader.tokens(in: #"{"formulae":[],"casks":[]}"#), [])
        XCTAssertNil(HomebrewOutdatedLoader.tokens(in: "Error: brew is broken"))
    }
}
