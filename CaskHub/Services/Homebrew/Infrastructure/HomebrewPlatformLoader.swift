//
//  HomebrewPlatformLoader.swift
//  CaskHub
//
//  Created by Ali Elsokary on 05/10/2026.
//

import Foundation

nonisolated struct HomebrewPlatformLoader: Sendable {
    @concurrent
    func load(from brewURL: URL?) async -> CaskPlatform? {
        guard let brewURL,
              let result = ProcessCapture.capture(
                  brewURL,
                  arguments: ["ruby", "-rjson", "-e", "puts JSON.generate(Homebrew::SimulateSystem.current_tag.to_s)"],
                  // Scope developer mode to this process so `brew ruby` does not persistently enable it.
                  environment: ["HOMEBREW_NO_AUTO_UPDATE": "1", "HOMEBREW_DEVELOPER": "1"]
              ),
              result.status == 0,
              let output = result.output,
              let tag = try? JSONDecoder().decode(String.self, from: Data(output.utf8)),
              !tag.isEmpty,
              tag.allSatisfy({ $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "_") })
        else { return nil }
        return CaskPlatform(tag: tag)
    }
}
