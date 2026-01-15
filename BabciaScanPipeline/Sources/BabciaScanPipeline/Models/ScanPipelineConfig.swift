//
//  ScanPipelineConfig.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import Foundation

public struct ScanPipelineConfig: Sendable {
    public let apiKey: String
    public let taskModelEndpoint: URL
    public let dreamModelEndpoint: URL
    public let taskTimeout: TimeInterval
    public let dreamTimeout: TimeInterval
    public let fallbackTasks: [String]
    public let fallbackAdvice: String

    public init(
        apiKey: String,
        taskModelEndpoint: URL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!,
        dreamModelEndpoint: URL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent")!,
        taskTimeout: TimeInterval = 30,
        dreamTimeout: TimeInterval = 120,
        fallbackTasks: [String] = [
            "Clear one surface",
            "Put away any loose items",
            "Wipe down a visible spot"
        ],
        fallbackAdvice: String = "Start small. You have got this."
    ) {
        self.apiKey = apiKey
        self.taskModelEndpoint = taskModelEndpoint
        self.dreamModelEndpoint = dreamModelEndpoint
        self.taskTimeout = taskTimeout
        self.dreamTimeout = dreamTimeout
        self.fallbackTasks = fallbackTasks
        self.fallbackAdvice = fallbackAdvice
    }
}
