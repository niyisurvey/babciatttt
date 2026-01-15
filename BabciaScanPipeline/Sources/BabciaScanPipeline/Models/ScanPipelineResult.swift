//
//  ScanPipelineResult.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import DreamRoomEngine
import Foundation

public struct ScanPipelineResult: Sendable {
    public let tasks: [String]
    public let advice: String
    public let dreamResult: DreamRoomResult?
    public let taskErrorMessage: String?
    public let dreamErrorMessage: String?

    public init(
        tasks: [String],
        advice: String,
        dreamResult: DreamRoomResult?,
        taskErrorMessage: String?,
        dreamErrorMessage: String?
    ) {
        self.tasks = tasks
        self.advice = advice
        self.dreamResult = dreamResult
        self.taskErrorMessage = taskErrorMessage
        self.dreamErrorMessage = dreamErrorMessage
    }
}
