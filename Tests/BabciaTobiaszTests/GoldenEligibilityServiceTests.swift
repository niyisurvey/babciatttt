// GoldenEligibilityServiceTests.swift
// BabciaTobiaszTests

import XCTest
@testable import BabciaTobiasz

@MainActor
final class GoldenEligibilityServiceTests: XCTestCase {

    func testEligibleWhenNeverVerified() {
        let service = GoldenEligibilityService()
        let user = User(dailyTarget: 1)
        let area = Area(name: "Test Area")
        let session = Session(area: area)

        let eligible = service.isEligibleForGolden(user: user, recentSessions: [session])

        XCTAssertTrue(eligible)
    }

    func testNotEligibleWhenRecentlyVerifiedAndOnTarget() {
        let service = GoldenEligibilityService()
        let user = User(dailyTarget: 1)
        let area = Area(name: "Test Area")
        let recentVerified = Session(area: area)
        recentVerified.verificationTier = .blue
        recentVerified.verificationPassed = true
        recentVerified.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()

        let todaySession = Session(area: area)
        todaySession.createdAt = Date()

        let eligible = service.isEligibleForGolden(user: user, recentSessions: [recentVerified, todaySession])

        XCTAssertFalse(eligible)
    }

    func testEligibleWhenLastVerificationThreeDaysAgo() {
        let service = GoldenEligibilityService()
        let user = User(dailyTarget: 1)
        let area = Area(name: "Test Area")
        let verified = Session(area: area)
        verified.verificationTier = .blue
        verified.verificationPassed = true
        verified.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()

        let todaySession = Session(area: area)
        todaySession.createdAt = Date()

        let eligible = service.isEligibleForGolden(user: user, recentSessions: [verified, todaySession])

        XCTAssertTrue(eligible)
    }

    func testEligibleWhenBehindDailyTarget() {
        let service = GoldenEligibilityService()
        let user = User(dailyTarget: 2)
        let area = Area(name: "Test Area")
        let verified = Session(area: area)
        verified.verificationTier = .blue
        verified.verificationPassed = true
        verified.createdAt = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let eligible = service.isEligibleForGolden(user: user, recentSessions: [verified])

        XCTAssertTrue(eligible)
    }
}
