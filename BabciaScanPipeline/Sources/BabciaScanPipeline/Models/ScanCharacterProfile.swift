//
//  ScanCharacterProfile.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import Foundation

public struct ScanCharacterProfile: Sendable {
    public let key: String
    public let displayName: String
    public let tagline: String
    public let voiceGuidance: String

    public init(
        key: String,
        displayName: String,
        tagline: String,
        voiceGuidance: String
    ) {
        self.key = key
        self.displayName = displayName
        self.tagline = tagline
        self.voiceGuidance = voiceGuidance
    }
}
