// ScoringServiceTests.swift
// BabciaTobiaszTests

import XCTest
@testable import BabciaTobiasz

@MainActor
final class ScoringServiceTests: XCTestCase {

    func testBluePassBonus() {
        let service = ScoringService()
        let bonus = service.calculateBonus(basePoints: 5, tier: .blue, passed: true)

        XCTAssertEqual(bonus, 15)
    }

    func testBlueFailBonusTruncates() {
        let service = ScoringService()
        let bonus = service.calculateBonus(basePoints: 5, tier: .blue, passed: false)

        XCTAssertEqual(bonus, 7)
    }

    func testGoldenPassBonus() {
        let service = ScoringService()
        let bonus = service.calculateBonus(basePoints: 5, tier: .golden, passed: true)

        XCTAssertEqual(bonus, 45)
    }

    func testGoldenFailBonusTruncates() {
        let service = ScoringService()
        let bonus = service.calculateBonus(basePoints: 5, tier: .golden, passed: false)

        XCTAssertEqual(bonus, 22)
    }

    func testApplyVerificationBonusMutatesSession() {
        let service = ScoringService()
        let area = Area(name: "Test Area")
        let session = Session(area: area, basePoints: 5)

        service.applyVerificationBonus(to: session, tier: .blue, passed: true)

        XCTAssertEqual(session.verificationTier, .blue)
        XCTAssertEqual(session.verificationPassed, true)
        XCTAssertEqual(session.bonusPoints, 15)
        XCTAssertEqual(session.totalPoints, 20)
    }
}
