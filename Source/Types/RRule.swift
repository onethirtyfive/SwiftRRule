//
//  RRule.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation

public struct RRule {
    public let raw: RFCRRule

    init(_ rfcRRule: RFCRRule) {
        self.raw = rfcRRule
    }
}

public struct NormalRRule {
    public let raw: RFCRRule

    init(_ rfcRRule: RFCRRule) {
        self.raw = rfcRRule
    }
}

public struct NormalValidRRule {
    public let raw: RFCRRule

    init(_ rfcRRule: RFCRRule) {
        self.raw = rfcRRule
    }
}

public struct Recurrable {
    public let
        rrule: RRule, // as provided by caller
        normalRRule: NormalRRule, // normalized, anchored where necessary
        normalValidRRule: NormalValidRRule // with valid details

    init(_ rfcRRule: RFCRRule) throws {
        // Series of data transformations--a pipeline, in essence, with loose type
        // guarantees provided at each step.
        //
        // The only interesting one should be `normalValidRRule`, except when debugging.
        let normalRFCRRule = rfcRRule.normal
        try normalRFCRRule.validate()

        self.rrule = RRule(rfcRRule)
        self.normalRRule = NormalRRule(normalRFCRRule)
        self.normalValidRRule = NormalValidRRule(normalRFCRRule)
    }

    public var byyearday: Multi<Number> { details.byyearday.flattened() }
    public var byweekno: Multi<Number> { details.byweekno.flattened() }
    public var bysetpos: Multi<Number> { details.bysetpos.flattened() }
    public var bymonth: Multi<Number> { details.bymonth.flattened() }
    public var bymonthday: Multi<Number> { partitionedBymonthday.each }
    public var bynmonthday: Multi<OrdNumber> { partitionedBymonthday.eachN }
    public var byweekday: Multi<Number> { partitionedByweekday.each }
    public var bynweekday: Multi<OrdNumber> { partitionedByweekday.eachN }
    public var byhour: Multi<Number> { details.byhour.flattened() }
    public var bysecond: Multi<Number> { details.bysecond.flattened() }
    public var byminute: Multi<Number> { details.byminute.flattened() }

    internal var partitionedBymonthday: Partition {
        details.bymonthday.partitioned(freq: parameters.freq)
    }
    internal var partitionedByweekday: Partition {
        details.byweekday.partitioned(freq: parameters.freq)
    }

    internal var parameters: RFCRRuleParameters { normalValidRRule.raw.parameters }
    internal var details: RFCRRuleDetails { normalValidRRule.raw.details }
}
