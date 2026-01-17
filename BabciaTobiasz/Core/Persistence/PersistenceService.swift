// PersistenceService.swift
// BabciaTobiasz

import Foundation
import SwiftData

@MainActor
final class PersistenceService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD
    
    func save() throws {
        try modelContext.save()
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }
    
    func fetchAll<T: PersistentModel>() throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    // MARK: - User

    /// Fetches the current user if one exists.
    func fetchUser() throws -> User? {
        var descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.id)])
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// Fetches the current user or creates a default one if missing.
    func fetchOrCreateUser() throws -> User {
        if let existing = try fetchUser() {
            return existing
        }
        let user = User()
        modelContext.insert(user)
        try modelContext.save()
        return user
    }
    
    // MARK: - Areas
    
    func fetchAreas() throws -> [Area] {
        var descriptor = FetchDescriptor<Area>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 200
        return try modelContext.fetch(descriptor)
    }
    
    func createArea(_ area: Area) throws {
        modelContext.insert(area)
        try modelContext.save()
    }
    
    func updateArea(_ area: Area) throws {
        try modelContext.save()
    }
    
    func deleteArea(_ area: Area) throws {
        modelContext.delete(area)
        try modelContext.save()
    }

    func fetchReminderConfig(for areaId: UUID) throws -> ReminderConfig? {
        let predicate = #Predicate<ReminderConfig> { config in
            config.areaId == areaId
        }
        var descriptor = FetchDescriptor<ReminderConfig>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func deleteReminderConfig(for areaId: UUID) throws {
        if let config = try fetchReminderConfig(for: areaId) {
            modelContext.delete(config)
            try modelContext.save()
        }
    }
    
    func createBowl(for area: Area, tasks: [CleaningTask], verificationRequested: Bool, beforePhotoData: Data?) throws -> AreaBowl {
        let bowl = AreaBowl(createdAt: Date(), verificationRequested: verificationRequested, beforePhotoData: beforePhotoData)
        bowl.area = area
        bowl.tasks = tasks
        area.bowls?.append(bowl)
        modelContext.insert(bowl)
        try modelContext.save()
        return bowl
    }
    
    func completeTask(_ task: CleaningTask) throws {
        task.completedAt = Date()
        try modelContext.save()
    }
    
    func uncompleteTask(_ task: CleaningTask) throws {
        task.completedAt = nil
        try modelContext.save()
    }
    
    func verifyBowl(_ bowl: AreaBowl, tier: BowlVerificationTier, outcome: BowlVerificationOutcome) throws {
        bowl.verificationTier = tier
        bowl.verificationOutcome = outcome
        bowl.verifiedAt = Date()
        try modelContext.save()
    }
    
}
