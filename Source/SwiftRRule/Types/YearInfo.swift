//
//  YearInfo2.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/24/21.
//

import Foundation
import SwiftDate

infix operator %%: MultiplicationPrecedence

public func %%<T: BinaryInteger>(lhs: T, rhs: T) -> T {
    let rem = lhs % rhs // -rhs <= rem <= rhs
    return rem >= 0 ? rem : rem + rhs
}

extension Array where Element == Patch {
    public func applyAll(to target: inout WeeknoMask) {
        forEach { patch in patch.apply(to: &target)}
    }
}

public struct Patch {
    let
        at: Number,
        change: [Number]

    public init(at: Number, _ change: [Number]) {
        self.at = at
        self.change = change
    }

    public func apply(to target: inout WeeknoMask) -> Void {
        target.replaceSubrange((at..<(at + change.count)), with: change)
    }
}

public struct PatchBuilder {
    public static func possibleLeadingPatch(_ thisYear: YearDetails, recurrable: Recurrable) -> Patch? {
        let
            recurrableDaysToWkst = thisYear.recurrableDaysToWkst,
            weekDayMask = thisYear.weekDayMask,
            recurrableDaysInYear = thisYear.recurrableDaysInYear,
            wkst = recurrable.wkst,
            byweekno = recurrable.byweekno,
            lastYear = thisYear.forYearPreceding

        if recurrableDaysToWkst != 0 {
            let builder = PatchBuilder(xref: weekDayMask, until: thisYear.daysFromNewYearsToWkst)

            // Move to YearDetail?
            let lastYearLiteralWeekOffset = lastYear.daysFromNewYearsToWkst >= 4
                ? lastYear.daysInYear + (lastYear.newYearsWeekDay - wkst) %% 7
                : recurrableDaysInYear - recurrableDaysToWkst
            let lastYearFinalWeekno = Int(floor(52.0 + Double(lastYearLiteralWeekOffset %% 7) / 4.0))

            return byweekno.contains(-1) || byweekno.contains(lastYearFinalWeekno)
                ? builder.patch(at: 0)
                : nil
        } else {
            return nil
        }
    }

    public static func possibleFirstPatch(_ thisYear: YearDetails, recurrable: Recurrable) -> Patch? {
        let
            wkst = recurrable.wkst,
            weekDayMask = thisYear.weekDayMask,
            byweekno = recurrable.byweekno,
            daysInYear = thisYear.daysInYear,
            daysFromNewYearsToWkst = thisYear.daysFromNewYearsToWkst,
            recurrableDaysToWkst = thisYear.recurrableDaysToWkst,
            recurrableWeeks = thisYear.recurrableWeeks

        guard byweekno.contains(1) == true else {
            return nil
        }

        let
            basis = recurrableDaysToWkst + recurrableWeeks * 7,
            at = recurrableDaysToWkst == daysFromNewYearsToWkst
                ? basis
                : basis - (7 - daysFromNewYearsToWkst)

        return at < daysInYear
            ? PatchBuilder(xref: weekDayMask, until: wkst).patch(at: at)
            : nil
    }

    public static func possibleCentralPatch(_ thisYear: YearDetails, recurrable: Recurrable,
        weekno: Number) -> Patch? {

        let
            recurrableWeeks = thisYear.recurrableWeeks,
            wkst = recurrable.wkst,
            recurrableDaysToWkst = thisYear.recurrableDaysToWkst,
            daysFromNewYearsToWkst = thisYear.daysFromNewYearsToWkst,
            weekDayMask = thisYear.weekDayMask

        let normalizedWeekno = weekno < 0
            ? recurrableWeeks + 1 - abs(weekno) // really subtracting from end of year
            : weekno

        if (1...recurrableWeeks).contains(normalizedWeekno) {
            let builder = PatchBuilder(xref: weekDayMask, until: wkst)
            var starting: Number

            if normalizedWeekno == 1 {
                starting = recurrableDaysToWkst
            } else {
                let basis = recurrableDaysToWkst + (normalizedWeekno - 1) * 7
                starting = recurrableDaysToWkst == daysFromNewYearsToWkst
                    ? basis
                    : basis - (7 - daysFromNewYearsToWkst)
            }

            return builder.patch(at: starting)
        } else {
            return nil
        }
    }

    let
        weekDayMask: WeekDayMask,
        stop: Number

    public init(xref weekDayMask: WeekDayMask, until stop: Number) {
        self.weekDayMask = weekDayMask
        self.stop = stop
    }

    public func patch(at starting: Number) -> Patch {
        var contents: [Number] = []

        for offset in (0..<7) {
            contents.append(1)
            if weekDayMask[starting + offset + 1] == stop {
                break
            }
        }

        return Patch(at: starting, contents)
    }
}

public struct YearWeeknoMask {
    let
        thisYear: YearDetails,
        recurrable: Recurrable

    public var computed: WeeknoMask {
        var
            mask: WeeknoMask = Array(repeating: 0, count: thisYear.daysInYear + 7),
            patches: [Patch?] = []

        let centralWeekPatches =
            recurrable.byweekno.map { (weekno) -> Patch? in
                return PatchBuilder.possibleCentralPatch(thisYear, recurrable: recurrable, weekno: weekno)
            }

        patches.append(PatchBuilder.possibleFirstPatch(thisYear, recurrable: recurrable))
        patches.append(PatchBuilder.possibleLeadingPatch(thisYear, recurrable: recurrable))
        patches.append(contentsOf: centralWeekPatches)

        patches.compactMap { $0 }.applyAll(to: &mask)

        return mask
    }

    public init(_ thisYear: YearDetails, recurrable: Recurrable) {
        self.thisYear = thisYear
        self.recurrable = recurrable
    }
}

public struct YearMasks {
    var
        month: MonthMask,
        posDay: DayMask,
        negDay: DayMask,
        weekDay: WeekDayMask,
        weekno: WeeknoMask? = nil

    public init(_ thisYear: YearDetails, recurrable: Recurrable) {
        if thisYear.isLeapYear {
            self.month = Constants.month366Mask
            self.posDay = Constants.posDay366Mask
            self.negDay = Constants.negDay366Mask
        } else {
            self.month = Constants.month365Mask
            self.posDay = Constants.posDay365Mask
            self.negDay = Constants.negDay365Mask
        }

        self.weekDay = thisYear.weekDayMask

        if recurrable.byweekno.isEmpty {
            self.weekno = nil
        } else {
            self.weekno = YearWeeknoMask(thisYear, recurrable: recurrable).computed
        }
    }
}

extension Calendar {
    public static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }
}

extension Date {
    public static func gregorianUTCNewYears(of year: Number) -> Date {
        Calendar.gregorianUTC.date(from: DateComponents(year: year))!
    }

    public var rruleWeekDay: RRuleWeekDay { WeekDay(rawValue: weekday)!.rruleWeekDay }

    public func ordinal(since reference: Number = 1) -> Number {
        let eraNewYears = Self.gregorianUTCNewYears(of: reference)
        return calendar.dateComponents([.day], from: eraNewYears, to: self).day! - 1
    }
}

public enum YearLength: Int {
    case normal = 365
    case leap = 366
}

public struct YearDetails {
    public let
        newYears: Date,
        wkst: Number

    public var forYearPreceding: YearDetails { YearDetails(year - 1, wkst: wkst) }
    public var forYearFollowing: YearDetails { YearDetails(year + 1, wkst: wkst) }

    public var newYearsWeekDay: Number { newYears.rruleWeekDay.rawValue }
    public var daysFromNewYearsToWkst: Number { (wkst + 7 - newYearsWeekDay) %% 7 } // FKA: naturalWeekOffset

    public var year: Number { newYears.year }
    public var isLeapYear: Bool { (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 }
    public var length: YearLength { isLeapYear ? .leap : .normal }
    public var daysInYear: Number { length.rawValue }
    public var trailingWeekDays: Number { recurrableDaysInYear %% 7 }
    public var weeks: Number { Int(floor(Double(recurrableDaysInYear) / 7.0)) }

    public var monthRange: MonthRange {
        if case .normal = length {
            return Constants.month365Range
        } else {
            return Constants.month366Range
        }
    }

    public var weekDayMask: WeekDayMask {
        let
            basis = Constants.weekDayMask,
            newYearsWeekDayOccurrence = basis.firstIndex(of: newYearsWeekDay)!
        return Array(basis[newYearsWeekDayOccurrence...])
    }

    public var recurrableDaysInYear: Number {
        daysFromNewYearsToWkst >= 4
            ? daysInYear + (newYearsWeekDay - wkst) %% 7
            : daysInYear - daysFromNewYearsToWkst
    }

    public var recurrableDaysToWkst: Number {
        daysFromNewYearsToWkst >= 4
            ? 0 // treat days preceding first natural week as their own week; aka, start on new years.
            : daysFromNewYearsToWkst // skip the first week
    }

    public var recurrableWeeks: Number { Number(floor(Double(weeks) + Double(trailingWeekDays) / 4.0)) }

    public init(_ year: Number, wkst: Number) {
        self.newYears = Date.gregorianUTCNewYears(of: year)
        self.wkst = wkst
    }
}

public struct Year {
    public let
        details: YearDetails,
        masks: YearMasks

    public init(_ year: Number, recurrable: Recurrable) {
        let details = YearDetails(year, wkst: recurrable.wkst)

        self.details = details
        self.masks = YearMasks(details, recurrable: recurrable)
    }
}
