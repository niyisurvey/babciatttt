//
//  TaskCompletionEvent.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import Foundation
import SwiftData

@Model
final class TaskCompletionEvent {
    var id: UUID
    var completedAt: Date
    var dayOfWeek: Int
    var hourOfDay: Int
    var taskTitle: String
    var taskPoints: Int
    var areaId: UUID?
    var areaName: String
    var personaRaw: String
    var bowlId: UUID?

    init(
        completedAt: Date,
        dayOfWeek: Int,
        hourOfDay: Int,
        taskTitle: String,
        taskPoints: Int,
        areaId: UUID?,
        areaName: String,
        personaRaw: String,
        bowlId: UUID?
    ) {
        self.id = UUID()
        self.completedAt = completedAt
        self.dayOfWeek = dayOfWeek
        self.hourOfDay = hourOfDay
        self.taskTitle = taskTitle
        self.taskPoints = taskPoints
        self.areaId = areaId
        self.areaName = areaName
        self.personaRaw = personaRaw
        self.bowlId = bowlId
    }
}
