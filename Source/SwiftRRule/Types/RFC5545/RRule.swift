//
//  RRule.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation
import SwiftDate

public struct RRuleWhence: Validatable {
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

public struct RRuleParameters {
    let dtstart: Date

    var
        freq: RRuleFreq = .yearly,
        interval: Int = 1,
        wkst: RRuleWeekDay = .monday(),
        count: Int? = nil,
        until: Date? = nil

    init(dtstart: Date) {
        self.dtstart = dtstart
    }

    public func validate() throws -> Void {
        // TODO: Validate until is after dtstart
    }
}

// MARK: -

public struct RRuleDetails {
    let
        freq: RRuleFreq,
        dtstart: Date

    public var
        // "Anchoring" is using a property of the rrule start date to define a detail.
        // * iff any of these details isAdequate, then rrule isAdequate
        // ‖ if rrule isAdequate, don't anchor; otherwise, anchor iff rrule freq appropriate
        // † as an additional condition to ‖, only anchor if absent
        // ‡ if absent and rrule freq appropriate, anchor regardless of rrule isAdequate
        // ¶ flattens to a sets of numbers
        // § partitions into two sets: numbers, and ordinal numbers (aka nth-number)
        byyearday = Byyearday(.none), // *¶
        byweekno = Byweekno(.none), // *¶
        bysetpos = Bysetpos(.none), // ¶
        bymonth = Bymonth(.none), // ‖†¶
        bymonthday = Bymonthday(.none), // *‖§
        byweekday = Byweekday(.none), // *‖§
        byhour = Byhour(.none), // ‡¶
        byminute = Byminute(.none), // ‡¶
        bysecond = Bysecond(.none) // ‡¶

    public var isAdequate: Bool {
        byyearday.isAdequate || byweekno.isAdequate || bymonthday.isAdequate || byweekday.isAdequate
    }

    public var normal: RRuleDetails {
        var
            bymonth = self.bymonth,
            bymonthday = self.bymonthday,
            byweekday = self.byweekday,
            byhour = self.byhour,
            byminute = self.byminute,
            bysecond = self.bysecond

        if !isAdequate {
            switch freq {
            case .yearly:
                if case .none = bymonth.detail {
                    let rruleMonth = RRuleMonth(rawValue: dtstart.month)!
                    bymonth = bymonth.anchored(to: rruleMonth)
                }
                bymonthday = bymonthday.anchored(to: dtstart.day)
            case .monthly:
                bymonthday = bymonthday.anchored(to: dtstart.day)
            case .weekly:
                let rruleWeekDay = RRuleWeekDay(rawValue: dtstart.weekday - 1)!
                byweekday = byweekday.anchored(to: rruleWeekDay)
            default:
                break
            }
        }

        if freq.isLessThanHourly, case .none = byhour.detail  {
            byhour = byhour.anchored(to: dtstart.hour)
        }

        if freq.isLessThanMinutely, case .none = byminute.detail  {
            byminute = byminute.anchored(to: dtstart.minute)
        }

        if freq.isLessThanSecondly, case .none = bysecond.detail  {
            bysecond = bysecond.anchored(to: dtstart.second)
        }

        return RRuleDetails(
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
}

// MARK: -

public struct RRule {
    let
        whence: RRuleWhence,
        parameters: RRuleParameters,
        details: RRuleDetails

    public var isAdequate: Bool { details.isAdequate }
    public var normal: RRule { RRule(whence, parameters, details.normal) }

    init(_ whence: RRuleWhence, _ parameters: RRuleParameters, _ details: RRuleDetails) {
        self.whence = whence
        self.parameters = parameters
        self.details = details
    }

    public func validate() throws -> Void {
        try whence.validate()
        try parameters.validate()
        try details.validate()
    }
}

// MARK: -

public struct NormalValidRRule {
    public let raw: RRule

    init(_ rrule: RRule) throws {
        try rrule.validate()
        self.raw = rrule.normal
    }
}
