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
    /// Cask tokens `brew outdated` lists, or nil when Homebrew cannot answer.
    @concurrent
    func load(from brewURL: URL?) async -> Set<String>? {
        // ponytail: no auto-update, so the list is as fresh as Homebrew's last update. Allow it if staleness shows up.
        guard let brewURL,
              let result = ProcessCapture.capture(
                  brewURL,
                  arguments: ["outdated", "--cask", "--json=v2"],
                  environment: ["HOMEBREW_NO_AUTO_UPDATE": "1"]
              )
        else { return nil }
        return Self.tokens(in: result.output ?? "")
    }

    static func tokens(in output: String) -> Set<String>? {
        (try? JSONDecoder().decode(OutdatedReport.self, from: Data(output.utf8)))
            .map { Set($0.casks.map(\.name)) }
    }
}

private nonisolated struct OutdatedReport: Decodable {
    struct Cask: Decodable { let name: String }
    let casks: [Cask]
}
