//
//  AppSchema.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [
        Area.self,
        AreaBowl.self,
        CleaningTask.self,
        TaskCompletionEvent.self,
        Session.self,
        User.self,
        ReminderConfig.self
    ]
}

enum AppSchema: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        SchemaV1.self
    ]

    static var stages: [MigrationStage] = []
}
