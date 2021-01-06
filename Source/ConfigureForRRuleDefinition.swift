//
//  ConfigureForRRuleDefinition.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//
//  The gist: Configurator transforms an RRuleDefinition into a Configuration.

import Foundation
import SwiftDate

// MARK: Internal primitive types

internal typealias Many<T: Hashable> = Set<T>

internal enum BimodalWeekDay: Hashable {
    case each(_: RFCWeekDay)
    case eachNth(_: RFCNthWeekDay)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .each(let weekDay): hasher.combine(weekDay)
        case .eachNth(let nWeekDay): hasher.combine(nWeekDay)
        }
    }
}

internal enum Input<T: Hashable> {
    case many(_: Many<T>)
    case one(T)
    case none
}

internal typealias OrdSetting = Input<Int>
internal typealias MonthSetting = Input<Month>
internal typealias BimodalWeekDaySetting = Input<BimodalWeekDay>

// MARK: - Argument/Return types

public struct RRuleDefinition {
    var outset: RFCOutset =
        RFCOutset(
            dtstart: Date(seconds: TimeInterval(Date().timeIntervalSince1970)),
            tzid: nil
        )
    var rrule: RFCRRule = RFCRRule()

    init(_ outset: RFCOutset, _ rrule: RFCRRule) {
        self.outset = outset
        self.rrule = rrule
    }
}

public struct Configuration {
    let outset: RFCOutset
    let recurrenceCriteria: RecurrenceCriteria
}

public struct RecurrenceCriteria {
    let freq: Frequency
    let interval: Int
    let wkst: RFCWeekDay
    let count: Int?
    let until: Date?
    let manySetpos: Many<Int>
    let manyMonth: Many<Month>
    let manyMonthday: Many<Int>
    let manyNmonthday: Many<Int>
    let manyYearday: Many<Int>
    let manyWeekno: Many<Int>
    let manyWeekDay: Many<RFCWeekDay>
    let manyNWeekDay: Many<RFCNthWeekDay>
    let manyHour: Many<Int>
    let manyMinute: Many<Int>
    let manySecond: Many<Int>
}

// MARK: - Failure modes

public enum GenerationError: Error {
    case
        invariantViolation(_ msg: String),
        invalidBysetpos(value: Int),
        invalidMonthOrdinal,
        invalidWeekdayOrdinal,
        nCannotBeZero
}

// MARK: - Input homogenization

internal func homogenizeBysetpos(_ rrule: RFCRRule) throws -> Many<Int> {
    switch rrule.bysetpos {
    case .many(let manySetpos):
        for setpos in manySetpos {
            if (setpos == 0 || !(-366...366).contains(setpos)) {
                throw GenerationError.invalidBysetpos(value: setpos)
            }
        }
        return manySetpos
    case .one(let setpos): return [setpos]
    case .none: return []
    }
}

internal func homogenizeByyearday(_ rrule: RFCRRule) -> Many<Int> {
    switch rrule.byyearday {
    case .many(let manyYearday): return manyYearday
    case .one(let yearday): return [yearday]
    case .none: return []
    }
}

internal func homogenizeBymonth(_ rrule: RFCRRule) -> Many<Month> {
    switch rrule.bymonth {
    case .many(let manyMonth): return manyMonth
    case .one(let month): return [month]
    case .none: return []
    }
}

internal func homogenizeByweekno(_ rrule: RFCRRule) -> Many<Int> {
    switch rrule.byweekno {
    case .many(let manyWeekno): return manyWeekno
    case .one(let weekno): return [weekno]
    case .none: return []
    }
}

internal func homogenizeByhour(_ rrule: RFCRRule, dtstart: Date) -> Many<Int> {
    switch rrule.byhour {
    case .many(let manyHour): return manyHour
    case .one(let hour): return [hour]
    case .none: return (rrule.freq < .hourly) ? [dtstart.hour] : []
    }
}

internal func homogenizeByminute(_ rrule: RFCRRule, dtstart: Date) -> Many<Int> {
    switch rrule.byminute {
    case .many(let manyMinute): return manyMinute
    case .one(let minute): return [minute]
    case .none: return (rrule.freq < .minutely) ? [dtstart.minute] : []
    }
}

internal func homogenizeBysecond(_ rrule: RFCRRule, dtstart: Date) -> Many<Int> {
    switch rrule.bysecond {
    case .many(let manySecond): return manySecond
    case .one(let second): return [second]
    case .none: return (rrule.freq < .secondly) ? [dtstart.second] : []
    }
}

// MARK: - Default recurrence criteria synthesis

internal func shouldDeriveDefaultRecurrenceCriteria(_ rrule: RFCRRule) -> Bool {
    var testWeekno: Bool
    switch rrule.byweekno {
    case .many(let manyWeekno): testWeekno = manyWeekno.isEmpty
    case .one(let weekno): testWeekno = weekno == 0
    case .none: testWeekno = true
    }

    var testYearday: Bool
    switch rrule.byyearday {
    case .many(let manyYearday): testYearday = manyYearday.isEmpty
    default: testYearday = true
    }

    var testMonthday: Bool
    switch rrule.bymonthday {
    case .many(let manyMonthday): testMonthday = manyMonthday.isEmpty
    case .one(let monthday): testMonthday = monthday == 0
    case .none: testMonthday = true
    }

    var testWeekDay: Bool
    switch rrule.byweekday {
    case .none: testWeekDay = true
    default: testWeekDay = false
    }

    let shouldSynthesizeBaselineConfiguration =
        testWeekno && testYearday && testMonthday && testWeekDay

    return shouldSynthesizeBaselineConfiguration
}

internal enum DerivedDefaultRecurrenceCriteria {
    case forFreqYearly(_ manyMonth: Many<Month>, _ manyMonthday: Many<Int>)
    case forFreqMonthly(_ manyMonthday: Many<Int>)
    case forFreqWeekly(_ bimodalWeekDay: BimodalWeekDay)
    case none
}

internal func deriveDefaultRecurrenceCriteria(_ rrule: RFCRRule, dtstart: Date)
    throws -> DerivedDefaultRecurrenceCriteria {

    let day = dtstart.day
    let weekdayOrd: Int = dtstart.weekday
    let monthOrd: Int = dtstart.month

    switch rrule.freq {
    case .yearly:
        switch rrule.bymonth {
        case .many(let manyMonth): return .forFreqYearly(manyMonth, [day])
        case .one(let month): return .forFreqYearly([month], [day])
        case .none:
            // SwiftDate's Month is zero-indexed; Date's month is one-indexed.
            guard let month = Month(rawValue: monthOrd - 1) else {
                throw GenerationError.invalidMonthOrdinal
            }
            return .forFreqYearly([month], [day])
        }
    case .monthly:
        return .forFreqMonthly([day])
    case .weekly:
        // SwiftDate's WeekDay and Date's weekday are both one-indexed.
        guard let weekday = WeekDay(rawValue: weekdayOrd) else {
            throw GenerationError.invalidWeekdayOrdinal
        }
        return .forFreqWeekly(.each(weekday.toRFCWeekDay()))
    default:
        return .none
    }
}

// MARK: - Input partitioning

internal func partitionMonthday(_ manyMonthday: Many<Int>) -> (Many<Int>, Many<Int>) {
    var _manyMonthday: Many<Int> = []
    var _manyNmonthday: Many<Int> = []

    for md in manyMonthday {
        if md > 0 { _manyMonthday.update(with: md) }
        if md < 0 { _manyNmonthday.update(with: md) }
    }
    return (_manyMonthday, _manyNmonthday)
}

internal func partitionWeekDay(_ manyBimodalWeekDay: Many<BimodalWeekDay>,
    freq: Frequency) -> (Many<RFCWeekDay>, Many<RFCNthWeekDay>) {

    var manyWeekDay: Many<RFCWeekDay> = []
    var manyNWeekDay: Many<RFCNthWeekDay> = []

    for bimodalWeekDay in manyBimodalWeekDay {
        switch bimodalWeekDay {
        case .each(let weekDay):
            manyWeekDay.update(with: weekDay)
        case .eachNth(let nWeekDay):
            if freq > .monthly {
                manyWeekDay.update(with: nWeekDay.toRFCWeekDay())
            } else {
                manyNWeekDay.update(with: nWeekDay)
            }
        }
    }
    return (manyWeekDay, manyNWeekDay)
}

// MARK: - Input start time rounding

// Drop fractional millisecond portion of seconds.
internal func roundDtstart(_ dtstart: Date) -> Date {
    let withoutMilliseconds: TimeInterval =
        TimeInterval(Int(dtstart.timeIntervalSince1970))
    return Date(seconds: withoutMilliseconds)
}

// MARK: -

public struct ConfigureForRRuleDefinition {
    let rruleDefinition: RRuleDefinition

    init(_ rruleDefinition: RRuleDefinition) {
        self.rruleDefinition = rruleDefinition
    }

    public func run() throws -> Configuration {
        let outset = self.rruleDefinition.outset
        let rrule = self.rruleDefinition.rrule

        let dtstart: Date = roundDtstart(outset.dtstart)
        let manySetpos = try homogenizeBysetpos(rrule)
        let manyYearday = homogenizeByyearday(rrule)
        let manyWeekno = homogenizeByweekno(rrule)
        let manyHour = homogenizeByhour(rrule, dtstart: dtstart)
        let manyMinute = homogenizeByminute(rrule, dtstart: dtstart)
        let manySecond = homogenizeBysecond(rrule, dtstart: dtstart)

        // variant: can be overridden below
        var manyMonth: Set<Month> = homogenizeBymonth(rrule)

        // invariant: always configured below
        var manyMonthday: Many<Int>? = nil
        var manyNmonthday: Many<Int> = []
        var manyWeekDay: Many<RFCWeekDay>? = nil
        var manyNWeekDay: Many<RFCNthWeekDay> = []

        if shouldDeriveDefaultRecurrenceCriteria(rrule) {
            switch (try deriveDefaultRecurrenceCriteria(rrule, dtstart: dtstart)) {
            case .forFreqYearly(let _manyMonth, let _manyMonthday):
                manyMonth = _manyMonth
                (manyMonthday, manyNmonthday) = partitionMonthday(_manyMonthday)
            case .forFreqMonthly(let _manyMonthday):
                (manyMonthday, manyNmonthday) = partitionMonthday(_manyMonthday)
            case .forFreqWeekly(let _bimodalWeekDay):
                (manyWeekDay, manyNWeekDay) =
                    partitionWeekDay([_bimodalWeekDay], freq: rrule.freq)
            case .none:
                break
            }
        }

        if manyMonthday == nil {
            switch rrule.bymonthday {
            case .many(let _manyMonthday):
                (manyMonthday, manyNmonthday) = partitionMonthday(_manyMonthday)
            case .one(let monthday):
                (manyMonthday, manyNmonthday) = partitionMonthday([monthday])
            case .none:
                (manyMonthday, manyNmonthday) = partitionMonthday([])
            }
        }

        if manyWeekDay == nil {
            switch rrule.byweekday {
            case .many(let manyBimodalWeekDay):
                (manyWeekDay, manyNWeekDay) =
                    partitionWeekDay(manyBimodalWeekDay, freq: rrule.freq)
            case .one(let bimodalWeekDay):
                (manyWeekDay, manyNWeekDay) =
                    partitionWeekDay([bimodalWeekDay], freq: rrule.freq)
            case .none:
                (manyWeekDay, manyNWeekDay) =
                    partitionWeekDay([], freq: rrule.freq)
            }
        }

        let configuredOutset = RFCOutset(dtstart: dtstart, tzid: outset.tzid)
        let configuredRecurrenceCriteria =
            RecurrenceCriteria(
                freq: rrule.freq, interval: rrule.interval, wkst: rrule.wkst,
                count: rrule.count, until: rrule.until,
                manySetpos: manySetpos, manyMonth: manyMonth,
                manyMonthday: manyMonthday!, manyNmonthday: manyNmonthday,
                manyYearday: manyYearday, manyWeekno: manyWeekno,
                manyWeekDay: manyWeekDay!, manyNWeekDay: manyNWeekDay,
                manyHour: manyHour, manyMinute: manyMinute,
                manySecond:manySecond
            )

        return
            Configuration(
                outset: configuredOutset,
                recurrenceCriteria: configuredRecurrenceCriteria
            )
    }
}
