//
//  CaskUpdateTarget.swift
//  CaskHub
//
//  Created by Ali Elsokary on 05/10/2026.
//

import Foundation

nonisolated struct CaskPlatform: Equatable, Sendable {
    let tag: String
}

nonisolated struct CaskUpdateTarget: Equatable, Sendable {
    let version: String
    let autoUpdates: Bool?
}

/// Homebrew variants replace complete fields, including explicit nulls.
/// Only fields used for update eligibility are retained here.
nonisolated struct CaskUpdateVariation: Decodable, Hashable, Sendable {
    private let version: String?
    private let autoUpdates: Bool?
    private let disabled: Bool?
    private let deprecated: Bool?
    private let fields: Set<CodingKeys>

    private enum CodingKeys: String, CodingKey {
        case version, autoUpdates, disabled, deprecated
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fields = Set(values.allKeys)
        version = try values.decodeIfPresent(String.self, forKey: .version)
        autoUpdates = try values.decodeIfPresent(Bool.self, forKey: .autoUpdates)
        disabled = try values.decodeIfPresent(Bool.self, forKey: .disabled)
        deprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated)
    }

    func target(inheriting cask: Cask) -> CaskUpdateTarget? {
        guard !(fields.contains(.disabled) ? disabled == true : cask.disabled),
              !(fields.contains(.deprecated) ? deprecated == true : cask.deprecated),
              let version = fields.contains(.version) ? version : cask.version,
              !version.isEmpty
        else { return nil }
        return CaskUpdateTarget(
            version: version,
            autoUpdates: fields.contains(.autoUpdates) ? autoUpdates : cask.autoUpdates
        )
    }
}

extension Cask {
    func updateTarget(for platform: CaskPlatform?) -> CaskUpdateTarget? {
        // A failed platform query cannot establish which version is compatible.
        guard let tag = platform?.tag else { return nil }
        if let supportedPlatforms, !supportedPlatforms.contains(tag) { return nil }
        if let variation = variations?[tag] { return variation.target(inheriting: self) }
        // Homebrew uses the base fields when a known platform has no override.
        guard !disabled, !deprecated, !version.isEmpty else { return nil }
        return CaskUpdateTarget(version: version, autoUpdates: autoUpdates)
    }
}
