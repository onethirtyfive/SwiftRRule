//
//  InputProcessing.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation
import SwiftDate

public enum Arg<T> {
    case many(_ :Array<T>)
    case one(T)
    case none

    init(many values: T...) {
        self = .many(values)
    }

    init(one value: T) {
        self = .one(value)
    }
}

typealias OrdArg = Arg<Int>
typealias MonthArg = Arg<Month>
typealias WeekDayArg = Arg<RFCWeekDay>

public struct Options {
    var dtstart: Date =
        Date(seconds: TimeInterval(Date().timeIntervalSince1970.rounded(.down)))
    var freq: Frequency = .yearly
    var interval: Int = 1
    var wkst: RFCWeekDay = .monday()
    var count: Int? = nil
    var until: Date? = nil
    var tzid: Zones? = nil
    var bysetpos: OrdArg = .none
    var bymonth: MonthArg = .none
    var bymonthday: OrdArg = .none
    var bynmonthday: OrdArg = .none
    var byyearday: OrdArg = .none
    var byweekno: OrdArg = .none
    var byweekday: WeekDayArg = .none
    var byhour: OrdArg = .none
    var byminute: OrdArg = .none
    var bysecond: OrdArg = .none
}

public struct Configuration {
    let dtstart: Date
    let freq: Frequency
    let interval: Int
    let wkst: RFCWeekDay
    let count: Int?
    let until: Date?
    let tzid: Zones?
    let bysetpos: [Int]
    let bymonth: [Month]
    let bymonthday: [Int]
    let bynmonthday: [Int]
    let byyearday: [Int]
    let byweekno: [Int]
    let byweekday: [RFCWeekDay]
    let bynweekday: [RFCWeekDay]
    let byhour: [Int]
    let byminute: [Int]
    let bysecond: [Int]
}

public struct Configuring {
    public enum OptionParsingError: Error {
        case
            invalidBysetpos(value: Int),
            invalidMonthOrdinal,
            invalidWeekdayOrdinal,
            nCannotBeZero
    }

    internal enum InferredFrequency {
        case yearly(bymonth: [Month], bymonthday: [Int])
        case monthly(bymonthday: [Int])
        case weekly(byweekday: [RFCWeekDay])
        case original(_ freq: Frequency)
    }

    internal static func inferFreq(_ options: Options, dtstart: Date) throws
        -> InferredFrequency {
        let testWeekno =  { () -> Bool in
            switch options.byweekno {
            case .many(let manyWeekno): return manyWeekno.isEmpty
            case .one(let weekno): return weekno == 0
            case .none: return true
            }
        }

        let testYearday = { () -> Bool in
            switch options.byyearday {
            case .many(let manyYearday): return manyYearday.isEmpty
            case .one(_), .none: return true
            }
        }

        let testMonthday = { () -> Bool in
            switch options.bymonthday {
            case .many(let manyMonthday): return manyMonthday.isEmpty
            case .one(let monthday): return monthday == 0
            case .none: return true
            }
        }

        let testWeekday = { () -> Bool in
            switch options.byweekday {
            case .many(_), .one(_): return false
            case .none: return true
            }
        }

        if (testWeekno() && testYearday() && testMonthday() && testWeekday()) {
            let day = dtstart.day
            let weekday: Int = dtstart.weekday
            let month = dtstart.month

            switch options.freq {
            case .yearly:
                switch options.bymonth {
                case .many(let manyMonth):
                    return .yearly(bymonth: manyMonth, bymonthday: [day])
                case .one(let month):
                    return .yearly(bymonth: [month], bymonthday: [day])
                case .none:
                    guard let _month = Month(rawValue: month) else {
                        throw OptionParsingError.invalidMonthOrdinal
                    }
                    return .yearly(bymonth: [_month], bymonthday: [day])
                }
            case .monthly:
                return .monthly(bymonthday: [day])
            case .weekly:
                guard let weekDay = WeekDay(rawValue: weekday) else {
                    throw OptionParsingError.invalidWeekdayOrdinal
                }
                return .weekly(byweekday: [weekDay.toRFCWeekDay()])
            default:
                return .original(options.freq)
            }
        } else {
            return .original(options.freq)
        }
    }

    internal static func deriveBysetpos(_ options: Options) throws -> [Int] {
        switch options.bysetpos {
        case .many(let manySetpos):
            for setpos in manySetpos {
                if (setpos == 0 || !(-366...366).contains(setpos)) {
                    throw OptionParsingError.invalidBysetpos(value: setpos)
                }
            }
            return manySetpos
        case .one(let setpos):
            return [setpos]
        case .none:
            return []
        }
    }

    internal static func deriveBymonth(_ options: Options) -> [Month] {
        switch options.bymonth {
        case .many(let manyMonth):
            return manyMonth
        case .one(let month): return [month]
        case .none: return []
        }
    }

    internal static func deriveByyearday(_ options: Options) -> [Int] {
        switch options.byyearday {
        case .many(let nYearDay): return nYearDay
        case .one(let yearDay): return [yearDay]
        case .none: return []
        }
    }

    internal static func deriveBymonthdayAndBynmonthday(_ options: Options)
        -> ([Int], [Int]) {
        switch options.bymonthday {
        case .many(_):
            var manyMonthday: [Int] = []
            var manyNmonthday: [Int] = []
            for md in manyMonthday {
                if (md > 0) { manyMonthday.append(md) }
                if (md < 0) { manyNmonthday.append(md) }
            }
            return (manyMonthday, manyNmonthday)
        case .one(let monthDay):
            return monthDay < 0 ? ([monthDay], []) : ([], [monthDay])
        case .none: return ([], [])
        }
    }

    internal static func deriveByweekno(_ options: Options) -> [Int] {
        switch options.byweekno {
        case .many(let manyWeekno): return manyWeekno
        case .one(let weekNo): return [weekNo]
        case .none: return []
        }
    }

    internal static func deriveByweekdayAndBynweekday(_ options: Options)
        -> ([RFCWeekDay], [RFCWeekDay]) {
        switch options.byweekday {
        case .many(let manyWeekday):
            var byweekday: [RFCWeekDay] = []
            var bynweekday: [RFCWeekDay] = []

            for weekDay in manyWeekday {
                if options.freq > .monthly {
                    byweekday.append(weekDay)
                } else {
                    switch weekDay {
                    case .monday(let n), .tuesday(let n), .wednesday(let n),
                         .thursday(let n), .friday(let n), .saturday(let n),
                         .sunday(let n):
                        if (n == nil) {
                            byweekday.append(weekDay)
                        } else {
                            bynweekday.append(weekDay)
                        }
                    }
                }
            }
            return (byweekday, bynweekday)
        case .one(let weekday):
            return ([weekday], [])
        case .none:
            return ([], [])
        }
    }

    internal static func deriveByhour(_ options: Options) -> [Int] {
        switch options.byhour {
        case .many(let manyHour): return manyHour
        case .one(let hour): return [hour]
        case .none:
            return (options.freq < .hourly) ? [options.dtstart.hour] : []
        }
    }

    internal static func deriveByminute(_ options: Options) -> [Int] {
        switch options.byminute {
        case .many(let manyMinute): return manyMinute
        case .one(let minute): return [minute]
        case .none:
            return (options.freq < .minutely) ? [options.dtstart.minute] : []
        }
    }

    internal static func deriveBysecond(_ options: Options) -> [Int] {
        switch options.bysecond {
        case .many(let manySecond): return manySecond
        case .one(let second): return [second]
        case .none:
            return (options.freq < .secondly) ? [options.dtstart.second] : []
        }
    }

    static public func configure(_ options: Options) throws -> Configuration {
        let inferredFrequency =
            try inferFreq(options, dtstart: options.dtstart)
        let bysetpos = try deriveBysetpos(options)
        let bymonth = deriveBymonth(options)
        let byyearday = deriveByyearday(options)
        let (bymonthday, bynmonthday) = deriveBymonthdayAndBynmonthday(options)
        let byweekno = deriveByweekno(options)
        let (byweekday, bynweekday) = deriveByweekdayAndBynweekday(options)
        let byhour = deriveByhour(options)
        let byminute = deriveByhour(options)
        let bysecond = deriveByhour(options)

        switch (inferredFrequency) {
        case .yearly(let manyMonth, let manyMonthday):
            let configuration =
                Configuration(dtstart: options.dtstart, freq: .yearly,
                    interval: options.interval, wkst: options.wkst,
                    count: options.count, until: options.until,
                    tzid: options.tzid, bysetpos: bysetpos,
                    bymonth: manyMonth, bymonthday: manyMonthday,
                    bynmonthday: bynmonthday, byyearday: byyearday,
                    byweekno: byweekno, byweekday: byweekday,
                    bynweekday: bynweekday, byhour: byhour, byminute: byminute,
                    bysecond: bysecond)
            return configuration
        case .monthly(let manyMonthday):
            let configuration =
                Configuration(dtstart: options.dtstart, freq: .monthly,
                    interval: options.interval, wkst: options.wkst,
                    count: options.count, until: options.until,
                    tzid: options.tzid, bysetpos: bysetpos,
                    bymonth: bymonth, bymonthday: manyMonthday,
                    bynmonthday: bynmonthday, byyearday: byyearday,
                    byweekno: byweekno, byweekday: byweekday,
                    bynweekday: bynweekday, byhour: byhour, byminute: byminute,
                    bysecond: bysecond)
            return configuration
        case .weekly(let manyWeekday):
            let configuration =
                Configuration(dtstart: options.dtstart, freq: .yearly,
                    interval: options.interval, wkst: options.wkst,
                    count: options.count, until: options.until,
                    tzid: options.tzid, bysetpos: bysetpos,
                    bymonth: bymonth, bymonthday: bymonthday,
                    bynmonthday: bynmonthday, byyearday: byyearday,
                    byweekno: byweekno, byweekday: manyWeekday,
                    bynweekday: bynweekday, byhour: byhour, byminute: byminute,
                    bysecond: bysecond)
            return configuration
        case .original(let freq):
            let configuration =
                Configuration(dtstart: options.dtstart, freq: freq,
                    interval: options.interval, wkst: options.wkst,
                    count: options.count, until: options.until,
                    tzid: options.tzid, bysetpos: bysetpos,
                    bymonth: bymonth, bymonthday: bymonthday,
                    bynmonthday: bynmonthday, byyearday: byyearday,
                    byweekno: byweekno, byweekday: byweekday,
                    bynweekday: bynweekday, byhour: byhour, byminute: byminute,
                    bysecond: bysecond)
            return configuration
        }
    }
}
