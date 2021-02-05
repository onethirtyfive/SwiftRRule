//
//  Recurrable.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/18/21.
//

import Foundation
import SwiftDate

public struct Recurrable {
    public let
        provided: RRule, // as provided by caller
        normalRRule: NormalRRule, // normalized provided
        normalValidRRule: NormalValidRRule // details are normalized (anchored, etc.)

    public var dtstart: Date { whence.dtstart }
    public var tzid: Zones? { whence.tzid }

    public var freq: Number { parameters.freq.rawValue }
    public var interval: Number { parameters.interval }
    public var wkst: Number { parameters.wkst.rawValue }
    public var count: Number? { parameters.count }
    public var until: Date? { parameters.until }

    public var byyearday: Multi<Number> { details.byyearday.flattened() }
    public var byweekno: Multi<Number> { details.byweekno.flattened() }
    public var bysetpos: Multi<Number> { details.bysetpos.flattened() }
    public var bymonth: Multi<Number> { details.bymonth.flattened() }
    public var bymonthday: Multi<Partitioned> { partitionedBymonthday.values }
    public var bynmonthday: Multi<Partitioned> { partitionedBymonthday.ordinals }
    public var byweekday: Multi<Partitioned> { partitionedByweekday.values }
    public var bynweekday: Multi<Partitioned> { partitionedByweekday.ordinals }
    public var byhour: Multi<Number> { details.byhour.flattened() }
    public var bysecond: Multi<Number> { details.bysecond.flattened() }
    public var byminute: Multi<Number> { details.byminute.flattened() }

    public init(_ rrule: RRule) throws {
        // A pipeline with minimal type guarantees.
        self.provided = rrule
        self.normalRRule = try NormalRRule(rrule)
        self.normalValidRRule = try NormalValidRRule(normalRRule)
    }

    internal var partitionedBymonthday: Multi<Partitioned> {
        details.bymonthday.partitioned(freq: parameters.freq)
    }

    internal var partitionedByweekday: Multi<Partitioned> {
        details.byweekday.partitioned(freq: parameters.freq)
    }

    internal var whence: RRuleWhence { normalValidRRule.raw.whence }
    internal var parameters: RRuleParameters { normalValidRRule.raw.parameters }
    internal var details: RRuleDetails { normalValidRRule.raw.details }
}
