//
//  RFC5545.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

public enum RFCWeekDay {
    case
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday

    public func toString() -> String {
        switch self {
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        case .sunday: return "SU"
        }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCWeekDay: Comparable {
    public static func < (lhs: RFCWeekDay, rhs: RFCWeekDay) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }

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
            return .sunday
        }
    }
}

extension RFCWeekDay: WeekDayCompat {
    public func toWeekDay() -> WeekDay {
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

// MARK: -

public enum RFCNthWeekDay: Hashable {
    case
        monday(_: Int = 0),
        tuesday(_: Int = 0),
        wednesday(_: Int = 0),
        thursday(_: Int = 0),
        friday(_: Int = 0),
        saturday(_: Int = 0),
        sunday(_: Int = 0)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .monday(let n), .tuesday(let n), .wednesday(let n),
             .thursday(let n), .friday(let n), .saturday(let n),
             .sunday(let n):
            hasher.combine(n)
        }
    }

    public func toString() -> String {
        switch self {
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        case .sunday: return "SU"
        }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCNthWeekDay: Comparable {
    public static func < (lhs: RFCNthWeekDay, rhs: RFCNthWeekDay) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }

    private static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.monday(_), _), (_, .monday(_)):
            return .monday()
        case (.tuesday(_), _), (_, .tuesday(_)):
            return .tuesday()
        case (.wednesday(_), _), (_, .wednesday(_)):
            return .wednesday()
        case (.thursday(_), _), (_, .thursday(_)):
            return .thursday()
        case (.friday(_), _), (_, .friday(_)):
            return .friday()
        case (.saturday(_), _), (_, .saturday(_)):
            return .saturday()
        case (.sunday(_), _), (_, .sunday(_)):
            return .sunday()
        }
    }
}

extension RFCNthWeekDay: RFCWeekDayCompat {
    public func toRFCWeekDay() -> RFCWeekDay {
        switch (self) {
        case .monday(_): return .monday
        case .tuesday(_): return .tuesday
        case .wednesday(_): return .wednesday
        case .thursday(_): return .thursday
        case .friday(_): return .friday
        case .saturday(_): return .saturday
        case .sunday(_): return .sunday
        }
    }
}

// MARK: -

public struct RFCOutset {
    var dtstart: Date = Date(seconds: TimeInterval(Date().timeIntervalSince1970))
    var tzid: Zones? = nil
}

public struct RFCRRule {
    var freq: Frequency = .yearly
    var interval: Int = 1
    var wkst: RFCWeekDay = .monday
    var count: Int? = nil
    var until: Date? = nil
    var bysetpos: OrdSetting = .none
    var bymonth: MonthSetting = .none
    var bymonthday: OrdSetting = .none
    var byyearday: OrdSetting = .none
    var byweekno: OrdSetting = .none
    var byweekday: BimodalWeekDaySetting = .none
    var byhour: OrdSetting = .none
    var byminute: OrdSetting = .none
    var bysecond: OrdSetting = .none
}
