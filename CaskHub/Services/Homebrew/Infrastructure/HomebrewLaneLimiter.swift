//
//  HomebrewLaneLimiter.swift
//  CaskHub
//
//  Created by Ali Elsokary on 05/10/2026.
//

import Foundation

/// Downloads run side by side up to a limit; everything else that changes Homebrew's state runs one at a time.
@MainActor
final class HomebrewLaneLimiter {
    enum Lane {
        case download
        case exclusive
    }

    static let shared = HomebrewLaneLimiter(downloadLimit: 10)

    private struct Waiter {
        let lane: Lane
        let token: String?
        let continuation: CheckedContinuation<Bool, Never>
    }

    private let downloadLimit: Int
    private var active: [Lane: Int] = [:]
    private var waiters: [Waiter] = []

    init(downloadLimit: Int) {
        self.downloadLimit = downloadLimit
    }

    /// Returns false when the wait was cancelled before a slot opened.
    func acquire(_ lane: Lane, token: String?, onWait: () -> Void) async -> Bool {
        guard active[lane, default: 0] >= (lane == .download ? downloadLimit : 1) else {
            active[lane, default: 0] += 1
            return true
        }
        onWait()
        return await withCheckedContinuation {
            waiters.append(Waiter(lane: lane, token: token, continuation: $0))
        }
    }

    func release(_ lane: Lane) {
        guard let next = waiters.firstIndex(where: { $0.lane == lane }) else {
            active[lane, default: 0] -= 1
            return
        }
        waiters.remove(at: next).continuation.resume(returning: true)
    }

    func cancelWaiting(token: String) -> Bool {
        guard let index = waiters.firstIndex(where: { $0.token == token }) else { return false }
        waiters.remove(at: index).continuation.resume(returning: false)
        return true
    }
}
