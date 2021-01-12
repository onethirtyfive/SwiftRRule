//
//  RRule.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation

public struct RRule {
    let rfcRRule: RFCRRule

    var normal: NormalRRule {
        get {
            let
                whence = rfcRRule.whence,
                parameters = rfcRRule.parameters,
                details = rfcRRule.details.anchored(
                    parameters.freq, // ex: .yearly, .monthly, etc.
                    to: whence.dtstart
                )

            return NormalRRule(whence, parameters, details)
        }
    }

    init(
        _ whence: RFCRRuleWhence,
        _ parameters: RFCRRuleParameters,
        _ details: RFCRRuleDetails
    ) {
        self.rfcRRule = RFCRRule(whence, parameters, details)
    }
}

public struct NormalRRule {
    let rfcRRule: RFCRRule

    init(
        _ whence: RFCRRuleWhence,
        _ parameters: RFCRRuleParameters,
        _ details: RFCRRuleDetails
    ) {
        self.rfcRRule = RFCRRule(whence, parameters, details)
    }

    public func validate() throws -> NormalValidRRule {
        try rfcRRule.validate()
        return NormalValidRRule(rfcRRule.whence, rfcRRule.parameters, rfcRRule.details)
    }
}

public struct NormalValidRRule {
    let rfcRRule: RFCRRule

    public var recurrable: Recurrable {
        return Recurrable(rfcRRule.whence, rfcRRule.parameters, rfcRRule.criteria)
    }

    init(
        _ whence: RFCRRuleWhence,
        _ parameters: RFCRRuleParameters,
        _ details: RFCRRuleDetails
    ) {
        self.rfcRRule = RFCRRule(whence, parameters, details)
    }
}

public struct Configuration {
    public let
        rrule: RRule, // built on rfcRRule provided by caller
        normalRRule: NormalRRule, // normalized, anchoring to dtstart if necessary
        normalValidRRule: NormalValidRRule, // with sane ordinals
        recurrable: Recurrable // workable record of recurrable

    init(_ rrule: RRule) throws {
        // Series of data transformations--a pipeline, in essence, with loose type
        // guarantees provided at each step.
        //
        // The only truly interesting one should be `recurrable`, except for when debugging.
        self.rrule = rrule
        self.normalRRule = rrule.normal
        self.normalValidRRule = try normalRRule.validate()
        self.recurrable = normalValidRRule.recurrable
    }

    init(_ rfcRRule: RFCRRule) throws {
        try self.init(RRule(rfcRRule.whence, rfcRRule.parameters, rfcRRule.details))
    }
}
