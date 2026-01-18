//
//  ReminderConfig.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

@Model
final class ReminderConfig {
    static let maxSlots = 3

    var id: UUID
    @Attribute(.unique) var areaId: UUID
    var area: Area?
    var isEnabled: Bool
    var slot1Time: Date?
    var slot2Time: Date?
    var slot3Time: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        area: Area,
        isEnabled: Bool = false,
        slot1Time: Date? = nil,
        slot2Time: Date? = nil,
        slot3Time: Date? = nil
    ) {
        self.id = UUID()
        self.area = area
        self.areaId = area.id
        self.isEnabled = isEnabled
        self.slot1Time = slot1Time
        self.slot2Time = slot2Time
        self.slot3Time = slot3Time
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var slotTimes: [Date?] {
        [slot1Time, slot2Time, slot3Time]
    }

    var activeSlotTimes: [Date] {
        slotTimes.compactMap { $0 }
    }

    func updateSlot(_ index: Int, time: Date?) {
        switch index {
        case 0: slot1Time = time
        case 1: slot2Time = time
        case 2: slot3Time = time
        default: break
        }
        updatedAt = Date()
    }

    var snapshot: ReminderConfigSnapshot {
        ReminderConfigSnapshot(
            isEnabled: isEnabled,
            slotTimes: slotTimes,
            areaName: area?.name,
            areaDescription: area?.areaDescription
        )
    }
}

struct ReminderConfigSnapshot: Sendable {
    let isEnabled: Bool
    let slotTimes: [Date?]
    let areaName: String?
    let areaDescription: String?
}
