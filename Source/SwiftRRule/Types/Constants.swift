//
//  Constants.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/13/21.
//

import Foundation
import SwiftDate

typealias WeekDayMask = [Number]
typealias MonthMask = [Number]
typealias MonthRange = [Number]
typealias DayMask = [Number]
typealias DayRange = [Number]
typealias WeeknoMask = [Number]

public enum Constants {
    // MARK: - Annual masks (weekdays for weeks)

    internal static let calendarWeekDays: [Number] =
        [
            RRuleWeekDay.sunday().rawValue,
            RRuleWeekDay.monday().rawValue,
            RRuleWeekDay.tuesday().rawValue,
            RRuleWeekDay.wednesday().rawValue,
            RRuleWeekDay.thursday().rawValue,
            RRuleWeekDay.friday().rawValue,
            RRuleWeekDay.saturday().rawValue
        ]

    // MARK: Public

    static let weekDayMask: WeekDayMask =
        Array(Array(repeating: calendarWeekDays, count: 55).joined())

    // MARK: - Annual masks, ranges (months for days)

    internal static let
        ja = MonthMask(repeating: RRuleMonth.january.rawValue, count: 31),
        fe29 = MonthMask(repeating: RRuleMonth.february.rawValue, count: 29),
        fe28 = MonthMask(repeating: RRuleMonth.february.rawValue, count: 28),
        mr = MonthMask(repeating: RRuleMonth.march.rawValue, count: 31),
        ap = MonthMask(repeating: RRuleMonth.april.rawValue, count: 30),
        my = MonthMask(repeating: RRuleMonth.may.rawValue, count: 31),
        jn = MonthMask(repeating: RRuleMonth.june.rawValue, count: 30),
        jl = MonthMask(repeating: RRuleMonth.july.rawValue, count: 31),
        au = MonthMask(repeating: RRuleMonth.august.rawValue, count: 31),
        se = MonthMask(repeating: RRuleMonth.september.rawValue, count: 30),
        oc = MonthMask(repeating: RRuleMonth.october.rawValue, count: 31),
        no = MonthMask(repeating: RRuleMonth.november.rawValue, count: 30),
        de = MonthMask(repeating: RRuleMonth.december.rawValue, count: 31),
        ex = MonthMask(repeating: RRuleMonth.january.rawValue, count: 7)

    // MARK: Public

    static let
        month365Mask: MonthMask =
            Array([ja, fe28, mr, ap, my, jn, jl, au, se, oc, no, de, ex].joined()),
        month365Range: DayRange =
            [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
        month366Mask: MonthMask =
            Array([ja, fe29, mr, ap, my, jn, jl, au, se, oc, no, de, ex].joined()),
        month366Range: DayRange =
            [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]

    // MARK: - Annual masks, ranges (days for months)

    internal static let
        m28: [Int] = Array((1...28)),
        m29: [Int] = Array((1...29)),
        m30: [Int] = Array((1...30)),
        m31: [Int] = Array((1...31)),
        mEx: [Int] = Array(Array(arrayLiteral: m31[0...6]).joined())

    internal static let
        n28: [Int] = Array((-28...(-1))),
        n29: [Int] = Array((-29...(-1))),
        n30: [Int] = Array((-30...(-1))),
        n31: [Int] = Array((-31...(-1))),
        nEx: [Int] = Array(Array(arrayLiteral: n31[0...6]).joined())

    // MARK: Public

    static let
        posDay366Mask: DayMask =
            Array([m31, m29, m31, m30, m31, m30, m31, m31, m30, m31, m30, m31, mEx].joined()),
        negDay366Mask: DayMask =
            Array([n31, n29, n31, n30, n31, n30, n31, n31, n30, n31, n30, n31, nEx].joined())

    static let
        posDay365Mask: DayMask =
            Array([m31, m28, m31, m30, m31, m30, m31, m31, m30, m31, m30, m31, mEx].joined()),
        negDay365Mask: DayMask =
            Array([n31, n28, n31, n30, n31, n30, n31, n31, n30, n31, n30, n31, nEx].joined())

    // MARK: - Public (other)

    static let pyWeekDays: [RRuleWeekDay] =
        [.monday(), .tuesday(), .wednesday(), .thursday(), .friday(), .saturday(), .sunday()]
}
