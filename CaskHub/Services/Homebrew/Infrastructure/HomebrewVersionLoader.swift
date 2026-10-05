//
//  HomebrewVersionLoader.swift
//  CaskHub
//
//  Created by Ali Elsokary on 25/07/2026.
//

import Foundation

nonisolated enum ProcessCapture {
    /// One pipe serves both streams: a single read cannot deadlock on a full sibling buffer.
    static func capture(
        _ executableURL: URL,
        arguments: [String],
        environment: [String: String]? = nil,
        mergeStderr: Bool = false
    ) -> (status: Int32, output: String?)? {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        if let environment {
            process.environment = ProcessInfo.processInfo.environment
                .merging(environment) { _, override in override }
        }
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = mergeStderr ? pipe : FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(data: data, encoding: .utf8))
    }
}

nonisolated struct HomebrewVersionLoader: Sendable {
    @concurrent
    func load(from brewURL: URL?) async -> String? {
        guard let brewURL,
              let result = ProcessCapture.capture(brewURL, arguments: ["--version"]),
              result.status == 0,
              let firstLine = result.output?.split(separator: "\n").first
        else { return nil }
        return firstLine.split(separator: " ").last.map(String.init)
    }
}

nonisolated struct HomebrewOutdatedLoader: Sendable {
    /// What `brew outdated` lists, or nil when Homebrew cannot answer.
    @concurrent
    func load(from brewURL: URL?) async -> HomebrewOutdatedReport? {
        // ponytail: no auto-update, so the list is as fresh as Homebrew's last update. Allow it if staleness shows up.
        guard let brewURL,
              let result = ProcessCapture.capture(
                  brewURL,
                  arguments: ["outdated", "--cask", "--json=v2"],
                  environment: ["HOMEBREW_NO_AUTO_UPDATE": "1"]
              )
        else { return nil }
        return Self.report(in: result.output ?? "")
    }

    static func report(in output: String) -> HomebrewOutdatedReport? {
        guard let decoded = try? JSONDecoder().decode(OutdatedOutput.self, from: Data(output.utf8)) else { return nil }
        let pinned = Set(decoded.casks.filter { $0.pinned == true }.map(\.name))
        return HomebrewOutdatedReport(upgradable: Set(decoded.casks.map(\.name)).subtracting(pinned), pinned: pinned)
    }
}

private nonisolated struct OutdatedOutput: Decodable {
    struct Cask: Decodable {
        let name: String
        let pinned: Bool?
    }

    let casks: [Cask]
}
