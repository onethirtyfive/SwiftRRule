//
//  Frequency.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation

public enum Frequency: String {
    case
        yearly = "YEARLY",
        monthly = "MONTHLY",
        weekly = "WEEKLY",
        daily = "DAILY",
        hourly = "HOURLY",
        minutely = "MINUTELY",
        secondly = "SECONDLY"
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension Frequency: Comparable {
    public static func < (lhs: Frequency, rhs: Frequency) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }

    private static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.yearly, _), (_, .yearly):
            return .yearly
        case (.monthly, _), (_, .monthly):
            return .monthly
        case (.weekly, _), (_, .weekly):
            return .weekly
        case (.daily, _), (_, .daily):
            return .daily
        case (.hourly, _), (_, .hourly):
            return .hourly
        case (.minutely, _), (_, .minutely):
            return .minutely
        case (.secondly, _), (_, .secondly):
            return .secondly
        }
    }

    public func isDailyOrGreater() -> Bool {
        return self < .hourly
    }
}
