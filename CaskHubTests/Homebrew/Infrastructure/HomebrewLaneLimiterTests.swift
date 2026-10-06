//
//  HomebrewLaneLimiterTests.swift
//  CaskHubTests
//
//  Created by Ali Elsokary on 05/10/2026.
//

@testable import CaskHub
import XCTest

@MainActor
final class HomebrewLaneLimiterTests: XCTestCase {
    func test_download_lane_admits_up_to_its_limit_and_queues_the_rest_in_order() async {
        let limiter = HomebrewLaneLimiter(downloadLimit: 2)
        var waited: [String] = []
        var granted: [String] = []

        for token in ["a", "b"] {
            let admitted = await limiter.acquire(.download, token: token) { waited.append(token) }
            XCTAssertTrue(admitted)
        }
        let waiters = ["c", "d"].map { token in
            Task { if await limiter.acquire(.download, token: token, onWait: { waited.append(token) }) { granted.append(token) } }
        }
        await settle { waited.count == 2 }
        XCTAssertEqual(waited, ["c", "d"])
        XCTAssertEqual(granted, [])

        limiter.release(.download)
        await settle { granted.count == 1 }
        XCTAssertEqual(granted, ["c"])

        limiter.release(.download)
        for waiter in waiters { await waiter.value }
        XCTAssertEqual(granted, ["c", "d"])
    }

    func test_lanes_do_not_block_each_other_and_exclusive_admits_one() async {
        let limiter = HomebrewLaneLimiter(downloadLimit: 1)
        var waited: [String] = []

        let install = await limiter.acquire(.exclusive, token: "install") { waited.append("install") }
        let download = await limiter.acquire(.download, token: "download") { waited.append("download") }
        XCTAssertTrue(install)
        XCTAssertTrue(download)
        XCTAssertEqual(waited, [])

        let second = Task { await limiter.acquire(.exclusive, token: "second") { waited.append("second") } }
        await settle { waited == ["second"] }
        limiter.release(.download)
        await settle { false }
        XCTAssertEqual(waited, ["second"])

        limiter.release(.exclusive)
        let admitted = await second.value
        XCTAssertTrue(admitted)
    }

    func test_cancelling_a_waiter_reports_false_keeps_order_and_leaks_no_slot() async {
        let limiter = HomebrewLaneLimiter(downloadLimit: 1)
        var waiting = 0
        let holder = await limiter.acquire(.download, token: "holder") {}
        XCTAssertTrue(holder)
        let cancelled = Task { await limiter.acquire(.download, token: "cancelled") { waiting += 1 } }
        let next = Task { await limiter.acquire(.download, token: "next") { waiting += 1 } }
        await settle { waiting == 2 }

        XCTAssertTrue(limiter.cancelWaiting(token: "cancelled"))
        XCTAssertFalse(limiter.cancelWaiting(token: "cancelled"))
        XCTAssertFalse(limiter.cancelWaiting(token: "holder"))
        let wasAdmitted = await cancelled.value
        XCTAssertFalse(wasAdmitted)

        limiter.release(.download)
        let nextAdmitted = await next.value
        XCTAssertTrue(nextAdmitted)
        limiter.release(.download)

        var waitedAgain = false
        let fresh = await limiter.acquire(.download, token: "fresh") { waitedAgain = true }
        XCTAssertTrue(fresh)
        XCTAssertFalse(waitedAgain)
    }

    private func settle(until condition: () -> Bool) async {
        for _ in 0 ..< 200 where !condition() {
            await Task.yield()
        }
    }
}
