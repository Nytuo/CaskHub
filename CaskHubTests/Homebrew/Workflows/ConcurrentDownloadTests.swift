//
//  ConcurrentDownloadTests.swift
//  CaskHubTests
//
//  Created by Ali Elsokary on 05/10/2026.
//

@testable import CaskHub
import XCTest

@MainActor
final class ConcurrentDownloadTests: XCTestCase {
    func test_operation_waiting_for_its_turn_reads_queued_and_starts_when_the_lane_frees() async {
        let executor = ControlledHomebrewCommandExecutor()
        let service = makeService(executor)

        let first = Task { try? await service.uninstall(token: "firefox") }
        await executor.waitForRequests(1)
        let second = Task { try? await service.uninstall(token: "gimp") }
        await settle { service.operationStore.state(for: "gimp")?.progress?.phase == .queued }

        XCTAssertEqual(service.operationStore.state(for: "gimp")?.progress?.phase, .queued)
        XCTAssertEqual(service.operationStore.state(for: "gimp")?.canCancel, false)
        service.cancelInstall(token: "gimp")
        XCTAssertEqual(service.operationStore.state(for: "gimp")?.progress?.phase, .queued)
        XCTAssertEqual(executor.requests.map(\.arguments), [["uninstall", "--cask", "firefox"]])

        executor.finish("firefox")
        await executor.waitForRequests(2)
        XCTAssertEqual(service.operationStore.state(for: "gimp")?.progress?.phase, .performing)
        XCTAssertEqual(executor.maxActive["uninstall"], 1)
        executor.finish("gimp")
        await first.value
        await second.value
        XCTAssertNil(service.operationStore.state(for: "gimp"))
        XCTAssertEqual(executor.cancelledTokens, [])
    }

    private func makeService(_ executor: ControlledHomebrewCommandExecutor) -> LocalHomebrewService {
        LocalHomebrewService(defaults: makeScratchDefaults("concurrent-\(UUID().uuidString)")) {
            $0.fileManager = NoFilesFileManager()
            $0.commandExecutor = executor
            $0.softwareScanner = EmptyInstalledSoftwareScanner()
            $0.askpassProvider = { URL(fileURLWithPath: "/private/tmp/caskhub-test-askpass-\($0)") }
            $0.brewBinaryProvider = { URL(fileURLWithPath: "/test/bin/brew") }
            $0.brewVersionProvider = { "test" }
        }
    }

    private func settle(until condition: () -> Bool) async {
        for _ in 0 ..< 500 where !condition() {
            await Task.yield()
        }
    }
}

@MainActor
final class ControlledHomebrewCommandExecutor: HomebrewCommandExecuting {
    private struct Pending {
        let request: HomebrewCommandRequest
        let continuation: CheckedContinuation<BrewProcessResult, Never>
    }

    private(set) var requests: [HomebrewCommandRequest] = []
    private(set) var cancelledTokens: [String] = []
    private(set) var maxActive: [String: Int] = [:]
    private var pending: [Pending] = []

    func execute(
        _ request: HomebrewCommandRequest,
        onStart: @escaping @MainActor @Sendable () -> Void,
        onChunk _: @escaping @MainActor @Sendable (String) -> Void
    ) async throws -> BrewProcessResult {
        requests.append(request)
        onStart()
        return await withCheckedContinuation { continuation in
            pending.append(Pending(request: request, continuation: continuation))
            let subcommand = request.arguments.first ?? ""
            maxActive[subcommand] = max(maxActive[subcommand, default: 0], running(subcommand).count)
        }
    }

    func cancel(token: String) -> Bool {
        guard pending.contains(where: { $0.request.token == token }) else { return false }
        cancelledTokens.append(token)
        return true
    }

    func running(_ subcommand: String) -> [String] {
        pending.filter { $0.request.arguments.first == subcommand }.map(\.request.token)
    }

    func finish(_ token: String, exitCode: Int32 = 0, signalled: Bool = false) {
        guard let index = pending.firstIndex(where: { $0.request.token == token }) else {
            return XCTFail("no running command for \(token)")
        }
        pending.remove(at: index).continuation.resume(
            returning: BrewProcessResult(exitCode: exitCode, output: "", wasTerminatedBySignal: signalled)
        )
    }

    func waitForRequests(_ count: Int) async {
        for _ in 0 ..< 2000 where requests.count < count {
            await Task.yield()
        }
    }
}
