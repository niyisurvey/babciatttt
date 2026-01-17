// PersistenceServiceTests.swift
// BabciaTobiaszTests

import XCTest
@testable import BabciaTobiasz

final class PersistenceServiceTests: XCTestCase {

    // MARK: - Model Tests

    func testHabitCreation() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertEqual(habit.name, "Test")
        XCTAssertEqual(habit.iconName, "star")
        XCTAssertEqual(habit.colorHex, "#FF0000")
    }

    func testHabitWithDescription() {
        let habit = Habit(
            name: "Exercise",
            description: "Daily workout",
            iconName: "figure.run",
            colorHex: "#00FF00"
        )

        XCTAssertEqual(habit.habitDescription, "Daily workout")
    }

    func testHabitCompletionStatus() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertFalse(habit.isCompletedToday)
        XCTAssertEqual(habit.todayCompletionCount, 0)
    }

    func testHabitStreakInitial() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertEqual(habit.currentStreak, 0)
        XCTAssertEqual(habit.totalCompletions, 0)
    }

}
