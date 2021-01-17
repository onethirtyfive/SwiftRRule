//
//  RFCWeekDay.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation
import SwiftDate

// Zero-indexed, unlike Apple's WeekDay. Makes math less painful.
// Also, monday is the first weekday in the order--Apple's WeekDay starts with Sunday.
public enum RFCWeekDay: Number {
    case
        monday = 0,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCWeekDay: Comparable {
    private static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.monday, _), (_, .monday):
            return .monday
        case (.tuesday, _), (_, .tuesday):
            return .tuesday
        case (.wednesday, _), (_, .wednesday):
            return .wednesday
        case (.thursday, _), (_, .thursday):
            return .thursday
        case (.friday, _), (_, .friday):
            return .friday
        case (.saturday, _), (_, .saturday):
            return .saturday
        case (.sunday, _), (_, .sunday):
            // technically unreachable, but here for exhaustiveness
            return .sunday
        }
    }

    public static func < (lhs: RFCWeekDay, rhs: RFCWeekDay) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }
}

extension RFCWeekDay: WeekDayInterop {
    var weekDay: WeekDay {
        switch self {
        case .monday: return .monday
        case .tuesday: return .tuesday
        case .wednesday: return .wednesday
        case .thursday: return .thursday
        case .friday: return .friday
        case .saturday: return .saturday
        case .sunday: return .sunday
        }
    }
}
