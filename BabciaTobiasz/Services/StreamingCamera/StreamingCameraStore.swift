//
//  StreamingCameraStore.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

@MainActor
final class StreamingCameraStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [StreamingCameraConfig] {
        let descriptor = FetchDescriptor<StreamingCameraConfig>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func insert(_ config: StreamingCameraConfig) throws {
        modelContext.insert(config)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }

    func delete(_ config: StreamingCameraConfig) throws {
        modelContext.delete(config)
        try modelContext.save()
    }
}
