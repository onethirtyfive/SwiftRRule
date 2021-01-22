//
//  RRuleFreq.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RRuleFreq: Int {
    case
        yearly = 0,
        monthly,
        weekly,
        daily,
        hourly,
        minutely,
        secondly

    public var isWeeklyOrMore: Bool { self > .monthly }
    public var isLessThanHourly: Bool { self < .hourly }
    public var isLessThanMinutely: Bool { self < .minutely }
    public var isLessThanSecondly: Bool { self < .secondly }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RRuleFreq: Comparable {
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
            // technically unreachable, but here for exhaustiveness
            return .secondly
        }
    }

    public static func < (lhs: RRuleFreq, rhs: RRuleFreq) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }
}
