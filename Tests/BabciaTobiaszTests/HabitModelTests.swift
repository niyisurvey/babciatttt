// HabitModelTests.swift
// BabciaTobiaszTests

import XCTest
import SwiftData
@testable import BabciaTobiasz

final class HabitModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testHabitInitialization() {
        let habit = Habit(
            name: "Exercise",
            description: "Daily workout",
            iconName: "figure.run",
            colorHex: "#FF5733"
        )
        
        XCTAssertEqual(habit.name, "Exercise")
        XCTAssertEqual(habit.habitDescription, "Daily workout")
        XCTAssertEqual(habit.iconName, "figure.run")
        XCTAssertEqual(habit.colorHex, "#FF5733")
        XCTAssertEqual(habit.targetFrequency, 1)
        XCTAssertFalse(habit.notificationsEnabled)
    }
    
    func testHabitInitializationWithAllParameters() {
        let reminderTime = Date()
        let habit = Habit(
            name: "Meditation",
            description: "Morning meditation",
            iconName: "brain.head.profile",
            colorHex: "#4A90D9",
            reminderTime: reminderTime,
            notificationsEnabled: true,
            targetFrequency: 2
        )
        
        XCTAssertEqual(habit.targetFrequency, 2)
        XCTAssertTrue(habit.notificationsEnabled)
        XCTAssertEqual(habit.reminderTime, reminderTime)
    }
    
    // MARK: - Completion Tests
    
    func testIsCompletedTodayInitiallyFalse() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertFalse(habit.isCompletedToday)
    }
    
    func testTodayCompletionCountInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.todayCompletionCount, 0)
    }
    
    func testCurrentStreakInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.currentStreak, 0)
    }
    
    func testTotalCompletionsInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.totalCompletions, 0)
    }
    
    // MARK: - Color Tests
    
    func testColorFromHex() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF5733")
        let color = habit.color
        
        XCTAssertNotNil(color)
    }
    
    // MARK: - Reminder Tests
    
    func testReminderTimeSet() {
        let components = DateComponents(hour: 9, minute: 30)
        let reminderTime = Calendar.current.date(from: components)!
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000", reminderTime: reminderTime)
        
        XCTAssertNotNil(habit.reminderTime)
    }
    
    func testReminderTimeNil() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000", reminderTime: nil)
        
        XCTAssertNil(habit.reminderTime)
    }
}
