//
//  ScoringService.swift
//  BabciaTobiasz
//
//  Calculates verification bonuses and applies scoring rules.
//

import Foundation

/// Scoring service implementing PRD multipliers for verification tiers.
@MainActor
final class ScoringService {

    /// Calculates the bonus points for a given verification tier and outcome.
    /// - Parameters:
    ///   - basePoints: Base points earned from tasks.
    ///   - tier: Verification tier used for the review.
    ///   - passed: Whether verification passed.
    /// - Returns: Bonus points to add on top of base points.
    func calculateBonus(
        basePoints: Int,
        tier: VerificationTier,
        passed: Bool
    ) -> Int {
        switch (tier, passed) {
        case (.blue, true):
            return AppConfigService.shared.verificationBluePoints
        case (.blue, false):
            return 0
        case (.golden, true):
            return AppConfigService.shared.verificationGoldenPoints
        case (.golden, false):
            return 0
        }
    }

    /// Applies verification results to a session and updates its bonus points.
    /// - Parameters:
    ///   - session: Session to mutate.
    ///   - tier: Verification tier used.
    ///   - passed: Whether verification passed.
    func applyVerificationBonus(
        to session: Session,
        tier: VerificationTier,
        passed: Bool
    ) {
        session.verificationTier = tier
        session.verificationPassed = passed
        session.bonusPoints = calculateBonus(
            basePoints: session.basePoints,
            tier: tier,
            passed: passed
        )
    }
}
