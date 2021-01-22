//
//  Recurrable.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/18/21.
//

import Foundation

public struct Recurrable {
    public let
        provided: RRule, // as provided by caller
        normalValidRRule: NormalValidRRule // details are normalized (anchored, etc.)

    init(_ rrule: RRule) throws {
        // A pipeline with minimal type guarantees.
        self.provided = rrule
        self.normalValidRRule = try NormalValidRRule(rrule)
    }

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

    internal var partitionedBymonthday: Multi<Partitioned> {
        details.bymonthday.partitioned(freq: parameters.freq)
    }

    internal var partitionedByweekday: Multi<Partitioned> {
        details.byweekday.partitioned(freq: parameters.freq)
    }

    internal var parameters: RRuleParameters { normalValidRRule.raw.parameters }
    internal var details: RRuleDetails { normalValidRRule.raw.details }
}
