//
//  RFC5545.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

public enum RFCFrequency: String {
    case
        yearly = "YEARLY",
        monthly = "MONTHLY",
        weekly = "WEEKLY",
        daily = "DAILY",
        hourly = "HOURLY",
        minutely = "MINUTELY",
        secondly = "SECONDLY"

    public var isDailyOrLessFrequent: Bool {
        get { self < .hourly }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCFrequency: Comparable {
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

    public static func < (lhs: RFCFrequency, rhs: RFCFrequency) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }
}

// MARK: -

public enum RFCWeekDay: String {
    case
        monday = "MO",
        tuesday = "TU",
        wednesday = "WE",
        thursday = "TH",
        friday = "FR",
        saturday = "SA",
        sunday = "SU"
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
        get {
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
}

// MARK: -

public enum RFCNWeekDay: Hashable {
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
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCNWeekDay: Equatable {
    public static func == (lhs: RFCNWeekDay, rhs: RFCNWeekDay) -> Bool {
        switch (lhs, rhs) {
        case
            (.monday(let leftN), .monday(let rightN)),
            (.tuesday(let leftN), .tuesday(let rightN)),
            (.wednesday(let leftN), .wednesday(let rightN)),
            (.thursday(let leftN), .thursday(let rightN)),
            (.friday(let leftN), .friday(let rightN)),
            (.saturday(let leftN), .saturday(let rightN)),
            (.sunday(let leftN), .sunday(let rightN)):
            return leftN == rightN
        default:
            return false
        }
    }
}

extension RFCNWeekDay: Comparable {
    public static func zeroCase(_ nWeekDay: RFCNWeekDay) -> Self {
        switch nWeekDay {
        case .monday(_):
            return .monday(0)
        case .tuesday(_):
            return .tuesday(0)
        case .wednesday(_):
            return .wednesday(0)
        case .thursday(_):
            return .thursday(0)
        case .friday(_):
            return .friday(0)
        case .saturday(_):
            return .saturday(0)
        case .sunday(_):
            return .sunday(0)
        }
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
            // technically unreachable, but here for exhaustiveness
            return .sunday()
        }
    }

    public static func < (lhs: RFCNWeekDay, rhs: RFCNWeekDay) -> Bool {
        // Comparison ignores 'n'
        let
            lhsZero = Self.zeroCase(lhs),
            rhsZero = Self.zeroCase(rhs)

        return lhsZero != rhsZero && lhsZero == Self.minimum(lhsZero, rhsZero)
    }
}

extension RFCNWeekDay: RFCWeekDayInterop {
    var rfcWeekDay: RFCWeekDay {
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

public enum BimodalWeekDay: Hashable {
    case each(_: RFCWeekDay)
    case eachN(_: RFCNWeekDay)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .each(let weekDay): hasher.combine(weekDay)
        case .eachN(let nWeekDay): hasher.combine(nWeekDay)
        }
    }
}

public enum Cardinality<T: Hashable & Equatable>: Equatable {
    case many(_: Multi<T>)
    case one(T)
    case none
}

public typealias Ord = Int
public typealias OrdDetail = Cardinality<Ord>
public typealias MonthDetail = Cardinality<Month>
public typealias BimodalWeekDayDetail = Cardinality<BimodalWeekDay>

// MARK: -

public enum RFCWhenceError: Error {
    case
        invalidMonth(value: Int),
        invalidWeekday(value: Int)
}

public struct RFCWhence {
    var
        dtstart: Date,
        tzid: Zones? = nil

    init(_ dtstart: Date? = nil, tzid: Zones? = nil) {
        let withTruncatedMilliseconds = { (_ dtstart: Date) -> Date in
            let withoutMilliseconds = TimeInterval(Int(dtstart.timeIntervalSince1970))
            return Date(seconds: withoutMilliseconds)
        }

        let dtstart = withTruncatedMilliseconds(
            dtstart ?? Date(seconds: TimeInterval(Date().timeIntervalSince1970))
        )

        self.dtstart = dtstart
        self.tzid = tzid
    }

    // TODO: Better failure mode semantics.
    public func validate(monthOrd: Int? = nil, weekdayOrd: Int? = nil)
        throws -> Void {

        let monthOrd = monthOrd ?? dtstart.date.month
        guard Month(rawValue: monthOrd - 1) != nil else {
            throw RFCWhenceError.invalidMonth(value: monthOrd)
        }

        let weekdayOrd = weekdayOrd ?? dtstart.date.weekday
        guard WeekDay(rawValue: weekdayOrd) != nil else {
            throw RFCWhenceError.invalidWeekday(value: weekdayOrd)
        }
    }
}

public typealias RFCRRuleWhence = RFCWhence

public struct RFCRRuleParameters {
    // These are propagated as-as in recurrence criteria.
    var
        freq: RFCFrequency = .yearly,
        interval: Int = 1,
        wkst: RFCWeekDay = .monday,
        count: Int? = nil,
        until: Date? = nil

    public func validate(monthOrd: Int? = nil, weekdayOrd: Int? = nil)
        throws -> Void {
    }
}

public enum RFCRRuleDetailsError: Error {
    case invalidSetpos(value: Int)
}

public struct RFCRRuleDetails: Equatable {
    // If the details are unanchored (have insufficient time details), these are inferred
    // for freq and dtstart in resulting criteria:
    var
        bymonth: MonthDetail = .none,
        bymonthday: OrdDetail = .none, // †
        byweekday: BimodalWeekDayDetail = .none // †
    // † these are also partitioned into and exposed as each/eachN subgroups in criteria

    var
        bysetpos: OrdDetail = .none,
        byyearday: OrdDetail = .none,
        byweekno: OrdDetail = .none,
        byhour: OrdDetail = .none,
        byminute: OrdDetail = .none,
        bysecond: OrdDetail = .none

    var isByweeknoAnchored: Bool {
            get {
            switch byweekno {
            case .many(let many):
                return !many.isEmpty
            case .one(let one):
                return one != 0
            case .none:
                return false
            }
        }
    }

    var isByyeardayAnchored: Bool {
        get {
            switch byyearday {
            case .many(let many):
                return !many.isEmpty
            default:
                return false
            }
        }
    }

    var isBymonthdayAnchored: Bool {
        get {
            switch bymonthday {
            case .many(let many):
                return !many.isEmpty
            case .one(let one):
                return one != 0
            case .none:
                return false
            }
        }
    }

    var isByweekdayAnchored: Bool {
        get {
            switch byweekday {
            case .many(let many):
                return !many.isEmpty
            case .one(_):
                return true
            default:
                return false
            }
        }
    }

    var isAnchored: Bool {
        get {
            // return testWeekno && testYearday && testMonthday && testWeekDay
            return
                isByweeknoAnchored &&
                isByyeardayAnchored &&
                isBymonthdayAnchored &&
                isByweekdayAnchored
        }
    }

    public func anchored(_ freq: RFCFrequency, to dtstart: Date) -> RFCRRuleDetails {
        if isAnchored {
            return self
        } else {
            var rrule = self

            switch freq {
            case .yearly:
                switch rrule.bymonth {
                case .many(let months):
                    rrule.bymonth = .many(months)
                case .one(let month):
                    rrule.bymonth = .one(month)
                case .none:
                    let month = Month(rawValue: dtstart.month - 1)!
                    rrule.bymonth = .one(month)
                }
                rrule.bymonthday = .one(dtstart.day)
            case .monthly:
                rrule.bymonthday = .one(dtstart.day)
            case .weekly:
                let weekDay = WeekDay(rawValue: dtstart.weekday)!
                rrule.byweekday = .one(.each(weekDay.rfcWeekDay))
            default:
                break
            }

            return rrule
        }
    }

    // TODO: Better failure mode semantics.
    public func validate(bysetpos: OrdDetail? = nil) throws -> Void {
        let
            bysetpos = bysetpos ?? self.bysetpos,
            testSetpos = { (setpos: Int) -> Bool in
                (-366...366).contains(setpos) && setpos != 0
            }

        switch bysetpos {
        case .many(let bysetpos):
            for setpos in bysetpos {
                guard testSetpos(setpos) else {
                    throw RFCRRuleDetailsError.invalidSetpos(value: setpos)
                }
            }
        case .one(let setpos):
            guard testSetpos(setpos) else {
                throw RFCRRuleDetailsError.invalidSetpos(value: setpos)
            }
        case .none: break
        }
    }
}

public struct RFCRRule {
    let
        whence: RFCRRuleWhence,
        parameters: RFCRRuleParameters,
        details: RFCRRuleDetails

    init(
        _ whence: RFCRRuleWhence,
        _ parameters: RFCRRuleParameters,
        _ details: RFCRRuleDetails
    ) {
        self.whence = whence
        self.parameters = parameters
        self.details = details
    }

    public func validate(monthOrd: Int? = nil, weekdayOrd: Int? = nil) throws {
        try whence.validate()
        try parameters.validate()
        try details.validate()
    }
}
