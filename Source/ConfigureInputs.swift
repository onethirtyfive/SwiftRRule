//
//  ConfigureInputs.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//
//  The gist: Transforms an Inputs into a Configuration.

import Foundation
import SwiftDate

// MARK: Internal primitive types

internal typealias Many<T: Hashable> = Set<T>

internal enum BimodalWeekDay: Hashable {
    case each(_: RFCWeekDay)
    case eachN(_: RFCNWeekDay)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .each(let weekDay): hasher.combine(weekDay)
        case .eachN(let nWeekDay): hasher.combine(nWeekDay)
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

public struct Inputs {
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
    let freq: RFCFrequency
    let interval: Int
    let wkst: RFCWeekDay
    let count: Int?
    let until: Date?

    let manyMonth: Many<Month>
    let manyMonthday: Many<Int>
    let manyNmonthday: Many<Int>
    let manyWeekDay: Many<RFCWeekDay>
    let manyNWeekDay: Many<RFCNWeekDay>

    let manySetpos: Many<Int>
    let manyYearday: Many<Int>
    let manyWeekno: Many<Int>
    let manyHour: Many<Int>
    let manyMinute: Many<Int>
    let manySecond: Many<Int>
}

// MARK: - Failure modes

public enum ConfigureError: Error {
    case
        invalidSetposOrdinal(value: Int),
        invalidMonthOrdinal(value: Int),
        invalidWeekdayOrdinal(value: Int)
}

// MARK: - Input homogenization

internal func homogenizeBysetpos(_ bysetpos: OrdSetting) throws -> Many<Int> {
    switch bysetpos {
    case .many(let manySetpos):
        for setpos in manySetpos {
            if (setpos == 0 || !(-366...366).contains(setpos)) {
                throw ConfigureError.invalidSetposOrdinal(value: setpos)
            }
        }
        return manySetpos
    case .one(let setpos): return [setpos]
    case .none: return []
    }
}

internal func homogenizeByyearday(_ byyearday: OrdSetting) -> Many<Int> {
    switch byyearday {
    case .many(let manyYearday): return manyYearday
    case .one(let yearday): return [yearday]
    case .none: return []
    }
}

internal func homogenizeBymonth(_ bymonth: MonthSetting) -> Many<Month> {
    switch bymonth {
    case .many(let manyMonth): return manyMonth
    case .one(let month): return [month]
    case .none: return []
    }
}

internal func homogenizeByweekno(_ byweekno: OrdSetting) -> Many<Int> {
    switch byweekno {
    case .many(let manyWeekno): return manyWeekno
    case .one(let weekno): return [weekno]
    case .none: return []
    }
}

internal func homogenizeByhour(_ byhour: OrdSetting, dtstart: Date, freq: RFCFrequency)
    -> Many<Int> {

    switch byhour {
    case .many(let manyHour): return manyHour
    case .one(let hour): return [hour]
    case .none: return (freq < .hourly) ? [dtstart.hour] : []
    }
}

internal func homogenizeByminute(_ byminute: OrdSetting, dtstart: Date,
    freq: RFCFrequency) -> Many<Int> {

    switch byminute {
    case .many(let manyMinute): return manyMinute
    case .one(let minute): return [minute]
    case .none: return (freq < .minutely) ? [dtstart.minute] : []
    }
}

internal func homogenizeBysecond(_ bysecond: OrdSetting, dtstart: Date,
    freq: RFCFrequency) -> Many<Int> {

    switch bysecond {
    case .many(let manySecond): return manySecond
    case .one(let second): return [second]
    case .none: return (freq < .secondly) ? [dtstart.second] : []
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

    let shouldDeriveDefaultRecurrenceCriteria =
        testWeekno && testYearday && testMonthday && testWeekDay

    return shouldDeriveDefaultRecurrenceCriteria
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
                throw ConfigureError.invalidMonthOrdinal(value: monthOrd)
            }
            return .forFreqYearly([month], [day])
        }
    case .monthly:
        return .forFreqMonthly([day])
    case .weekly:
        // SwiftDate's WeekDay and Date's weekday are both one-indexed.
        guard let weekday = WeekDay(rawValue: weekdayOrd) else {
            throw ConfigureError.invalidWeekdayOrdinal(value: weekdayOrd)
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
    freq: RFCFrequency) -> (Many<RFCWeekDay>, Many<RFCNWeekDay>) {

    var manyWeekDay: Many<RFCWeekDay> = []
    var manyNWeekDay: Many<RFCNWeekDay> = []

    for bimodalWeekDay in manyBimodalWeekDay {
        switch bimodalWeekDay {
        case .each(let weekDay):
            manyWeekDay.update(with: weekDay)
        case .eachN(let nWeekDay):
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

public struct ConfigureInputs {
    let inputs: Inputs

    init(_ inputs: Inputs) {
        self.inputs = inputs
    }

    public func run() throws -> Configuration {
        let rrule = self.inputs.rrule
        let dtstart: Date = roundDtstart(inputs.outset.dtstart)

        var manyMonth: Set<Month>? = homogenizeBymonth(rrule.bymonth)
        var manyMonthday: Many<Int>? = nil
        var manyNmonthday: Many<Int> = []
        var manyWeekDay: Many<RFCWeekDay>? = nil
        var manyNWeekDay: Many<RFCNWeekDay> = []

        if shouldDeriveDefaultRecurrenceCriteria(self.inputs.rrule) {
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
                (manyWeekDay, manyNWeekDay) = partitionWeekDay([], freq: rrule.freq)
            }
        }

        let manySetpos = try homogenizeBysetpos(rrule.bysetpos)
        let manyYearday = homogenizeByyearday(rrule.byyearday)
        let manyWeekno = homogenizeByweekno(rrule.byweekno)
        let manyHour = homogenizeByhour(rrule.byhour, dtstart: dtstart, freq: rrule.freq)
        let manyMinute = homogenizeByminute(rrule.byminute, dtstart: dtstart, freq: rrule.freq)
        let manySecond = homogenizeBysecond(rrule.bysecond, dtstart: dtstart, freq: rrule.freq)

        let recurrenceCriteria =
            RecurrenceCriteria(
                freq: rrule.freq,
                interval: rrule.interval,
                wkst: rrule.wkst,
                count: rrule.count,
                until: rrule.until,

                // All force-unwrapped optionals are guaranteed non-nil by now
                manyMonth: manyMonth!,
                manyMonthday: manyMonthday!,
                manyNmonthday: manyNmonthday,
                manyWeekDay: manyWeekDay!,
                manyNWeekDay: manyNWeekDay,

                manySetpos: manySetpos,
                manyYearday: manyYearday,
                manyWeekno: manyWeekno,
                manyHour: manyHour,
                manyMinute: manyMinute,
                manySecond: manySecond
            )

        return
            Configuration(
                outset: RFCOutset(dtstart: dtstart, tzid: self.inputs.outset.tzid),
                recurrenceCriteria: recurrenceCriteria
            )
    }
}
