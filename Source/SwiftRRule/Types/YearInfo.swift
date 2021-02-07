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

extension Array where Element == YearWeeknoMask.Patch {
    public func applyAll(to target: inout WeeknoMask) {
        forEach { patch in patch.apply(to: &target)}
    }
}

public struct YearWeeknoMask {
    public struct Patch {
        let
            at: Number,
            change: [Number]

        public static func builder(terminus: Number, using weekDayMask: WeekDayMask) ->
            (_: Number) -> Self {
            
            { starting in
                var contents: [Number] = []

                for offset in (0..<7) {
                    contents.append(1)
                    if weekDayMask[starting + offset + 1] == terminus {
                        break
                    }
                }

                return Self(at: starting, contents)
            }
        }

        public init(at: Number, _ change: [Number]) {
            self.at = at
            self.change = change
        }

        public func apply(to target: inout WeeknoMask) -> Void {
            target.replaceSubrange((at..<(at + change.count)), with: change)
        }
    }

    public let
        normalByweekno: Multi<Number>,
        normalWkst: Number,
        weekDayMask: WeekDayMask,

        computedWeeks: Number,
        naturalWeekOffset: Number,
        computedWeekOffset: Number,
        length: Number,
        yearLength: Number,

        priorNewYearsWeekDay: Number,
        priorYearLength: Number

    internal var leadingWeekPatch: Patch? {
        guard computedWeekOffset != 0 else {
            return nil
        }

        var
            priorComputedFinalWeek: Number,
            priorComputedWeekOffset: Number = (normalWkst + 7 - priorNewYearsWeekDay) %% 7

        if normalByweekno.contains(-1) {
            priorComputedFinalWeek = -1
        } else {
            let priorLiteralWeekOffset = priorComputedWeekOffset >= 4
                ? priorYearLength + (priorNewYearsWeekDay - normalWkst) %% 7
                : length - computedWeekOffset
            priorComputedFinalWeek = Int(floor(52.0 + Double(priorLiteralWeekOffset %% 7) / 4.0))
        }

        if normalByweekno.contains(priorComputedFinalWeek) {
            let patchBuilder = Patch.builder(terminus: priorComputedWeekOffset, using: weekDayMask)
            return patchBuilder(0)
        } else {
            return nil
        }
    }

    internal var firstWeekPatch: Patch? {
        let patchBuilder = Patch.builder(terminus: normalWkst, using: weekDayMask)

        if normalByweekno.contains(1) {
            // Check week #1 of next year as well
            let basis = computedWeekOffset + computedWeeks * 7

            let at = computedWeekOffset == naturalWeekOffset
                ? basis
                : basis - (7 - naturalWeekOffset)

            return at < yearLength
                ? patchBuilder(at)
                : nil
        } else {
            return nil
        }
    }

    internal var centralWeekPatches: [Patch?] {
        let patchBuilder = Patch.builder(terminus: normalWkst, using: weekDayMask)

        return
            normalByweekno.map { (weekno) -> Patch? in
                let normalizedWeekno = weekno < 0
                    ? weekno + computedWeeks + 1 // really subtracting from end of year
                    : weekno
                var at: Number

                if (1...computedWeeks).contains(normalizedWeekno) {
                    if normalizedWeekno == 1 {
                        at = computedWeekOffset
                    } else {
                        let basis = computedWeekOffset + (normalizedWeekno - 1) * 7
                        at = computedWeekOffset == naturalWeekOffset
                            ? basis
                            : basis - (7 - naturalWeekOffset)
                    }

                    return patchBuilder(at)
                } else {
                    return nil
                }
            }
    }

    public var computed: WeeknoMask {
        var
            mask: WeeknoMask = Array(repeating: 0, count: yearLength + 7),
            patches: [Patch?] = []

        patches.append(firstWeekPatch)
        patches.append(contentsOf: centralWeekPatches)
        patches.append(leadingWeekPatch)

        patches.compactMap { $0 }.applyAll(to: &mask)

        return mask
    }

    public init(_ timespan: YearTimespan, recurrable: Recurrable) {
        let
            thisYear = timespan.thisYear,
            thisYearNewYears = thisYear.newYears

        let
            wkst = recurrable.wkst,
            byweekno = recurrable.byweekno

        self.normalWkst = wkst
        self.normalByweekno = byweekno
        self.weekDayMask = thisYear.weekDayMask

        self.naturalWeekOffset = (wkst + 7 - thisYearNewYears.rruleWeekDay.rawValue) %% 7
        self.yearLength = thisYear.length.rawValue

        if naturalWeekOffset >= 4 {
            let
                length = (thisYearNewYears.rruleWeekDay.rawValue - wkst) %% 7 + yearLength,
                literalWeeks = Int(floor(Double(length) / 7.0)),
                excessWeekDays = length %% 7

            self.length = length
            self.computedWeekOffset = 0
            self.computedWeeks = Number(floor(Double(literalWeeks) + Double(excessWeekDays) / 4.0))
        } else {
            let
                length = yearLength - naturalWeekOffset,
                literalWeeks = Int(floor(Double(length) / 7.0)),
                excessWeekDays = length %% 7

            self.length = length
            self.computedWeekOffset = naturalWeekOffset
            self.computedWeeks = Number(floor(Double(literalWeeks) + Double(excessWeekDays) / 4.0))
        }

        // FIXME: Ugly.
        self.priorYearLength = timespan.lastYear.length.rawValue
        self.priorNewYearsWeekDay = timespan.lastYear.newYears.rruleWeekDay.rawValue
    }
}

public struct YearMasks {
    var
        month: MonthMask,
        posDay: DayMask,
        negDay: DayMask,
        weekDay: WeekDayMask,
        weekno: WeeknoMask? = nil

    public init(_ timespan: YearTimespan, recurrable: Recurrable) {
        let thisYear = timespan.thisYear

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
            self.weekno = YearWeeknoMask(timespan, recurrable: recurrable).computed
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
    public let newYears: Date

    public var year: Number { newYears.year }
    public var isLeapYear: Bool { (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 }
    public var length: YearLength { isLeapYear ? .leap : .normal }

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
            newYearsWeekDayOccurrence = basis.firstIndex(of: newYears.rruleWeekDay.rawValue)!
        return Array(basis[newYearsWeekDayOccurrence...])
    }

    public init(_ year: Number) {
        self.newYears = Date.gregorianUTCNewYears(of: year)
    }
}

public struct YearTimespan {
    public let
        thisYear: YearDetails,
        lastYear: YearDetails,
        nextYear: YearDetails

    public var year: Number { thisYear.year }

    public init(_ year: Number) {
        self.thisYear = YearDetails(year)
        self.lastYear = YearDetails(year - 1)
        self.nextYear = YearDetails(year + 1)
    }
}

public struct Year {
    public let
        timespan: YearTimespan,
        masks: YearMasks

    public init(_ year: Number, recurrable: Recurrable) {
        let timespan = YearTimespan(year)

        self.timespan = timespan
        self.masks = YearMasks(timespan, recurrable: recurrable)
    }
}
