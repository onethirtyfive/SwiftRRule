//
//  RFCRRule.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation
import SwiftDate

public enum RFCWhenceError: Error {
    case
        invalidMonth(value: Int),
        invalidWeekday(value: Int)
}

public struct RFCRRuleWhence: Validatable {
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

    public func validate() throws -> Void {
        // TODO: Validate sanity of year.
    }
}

// MARK: -

public struct RFCRRuleParameters {
    let
        dtstart: Date

    var
        freq: RFCFrequency = .yearly,
        interval: Int = 1,
        wkst: RFCWeekDay = .monday,
        count: Int? = nil,
        until: Date? = nil

    public func validate() throws -> Void {
        // TODO: Validate until is after dtstart
    }

    init(dtstart: Date) {
        self.dtstart = dtstart
    }
}

// MARK: -

public struct RFCRRuleDetails: Validatable {
    let
        freq: RFCFrequency,
        dtstart: Date

    public var
        // "Anchoring" is using a property of the rrule start date to define a detail.
        // * iff any of these details isAdequate, then rrule isAdequate
        // ‖ if rrule isAdequate, don't anchor; otherwise, anchor iff rrule freq appropriate
        // † as an additional condition to ‖, only anchor if absent
        // ‡ if absent and rrule freq appropriate, anchor regardless of rrule isAdequate
        // ¶ flattens to a sets of numbers
        // § partitions into two sets: numbers, and ordinal numbers (aka nth-number)
        byyearday: RFCDetailYearday = .none, // *¶
        byweekno: RFCDetailWeekno = .none, // *¶
        bysetpos: RFCDetailSetpos = .none, // ¶
        bymonth: RFCDetailMonth = .none, // ‖†¶
        bymonthday: RFCDetailMonthday = .none, // *‖§
        byweekday: RFCDetailWeekDay = .none, // *‖§
        byhour: RFCDetailHour = .none, // ‡¶
        byminute: RFCDetailMinute = .none, // ‡¶
        bysecond: RFCDetailSecond = .none // ‡¶

    public func validate() throws -> Void {
        try byyearday.validate()
        try byweekno.validate()
        try bysetpos.validate()
        try bymonth.validate()
        try bymonthday.validate()
        try byweekday.validate()
        try byhour.validate()
        try byminute.validate()
        try bysecond.validate()
    }

    public var isAdequate: Bool {
        byyearday.isAdequate || byweekno.isAdequate || bymonthday.isAdequate || byweekday.isAdequate
    }

    public var normal: RFCRRuleDetails {
        var
            bymonth: RFCDetailMonth = self.bymonth,
            bymonthday: RFCDetailMonthday = self.bymonthday,
            byweekday: RFCDetailWeekDay = self.byweekday,
            byhour: RFCDetailHour = self.byhour,
            byminute: RFCDetailMinute = self.byminute,
            bysecond: RFCDetailSecond = self.bysecond

        if !isAdequate {
            // possible to anchor bymonth, bymonthday, and byweekday
            switch freq {
            case .yearly:
                if case .none = bymonth {
                    let month = RFCMonth(rawValue: dtstart.month - 1)!
                    bymonth = bymonth.anchored(to: month)
                }
                bymonthday = bymonthday.anchored(to: dtstart.day)
            case .monthly:
                bymonthday = bymonthday.anchored(to: dtstart.day)
            case .weekly:
                let weekDay = RFCWeekDay(rawValue: dtstart.weekday - 1)!
                byweekday = byweekday.anchored(to: .each(weekDay))
            default:
                break
            }
        }

        if freq.isLessThanHourly, case .none = byhour  {
            byhour = byhour.anchored(to: dtstart.hour)
        }

        if freq.isLessThanMinutely, case .none = byminute  {
            byminute = byminute.anchored(to: dtstart.minute)
        }

        if freq.isLessThanSecondly, case .none = bysecond  {
            bysecond = bysecond.anchored(to: dtstart.second)
        }

        return RFCRRuleDetails(
            freq: freq,
            dtstart: dtstart,
            byyearday: byyearday,
            byweekno: byweekno,
            bysetpos: bysetpos,
            bymonth: bymonth,
            bymonthday: bymonthday,
            byweekday: byweekday,
            byhour: byhour,
            byminute: byminute,
            bysecond: bysecond
        )
    }
}

// MARK: -

public struct RFCRRule: Validatable {
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

    public func validate() throws -> Void {
        try whence.validate()
        try parameters.validate()
        try details.validate()
    }

    public var normal: RFCRRule { RFCRRule(whence, parameters, details.normal) }

    public var isAdequate: Bool {
        details.isAdequate
    }
}
