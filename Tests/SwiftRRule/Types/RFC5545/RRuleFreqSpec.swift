//
//  RRuleFreqSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class RRuleFreqSpec: QuickSpec {
    override func spec() {
        it("exposes a handful of specific working comparisons") {
            expect(RRuleFreq.yearly.isWeeklyOrMore).to(beFalse())
            expect(RRuleFreq.daily.isWeeklyOrMore).to(beTrue())
            expect(RRuleFreq.daily.isLessThanHourly).to(beTrue())
            expect(RRuleFreq.hourly.isLessThanHourly).to(beFalse())
            expect(RRuleFreq.daily.isLessThanHourly).to(beTrue())
            expect(RRuleFreq.minutely.isLessThanMinutely).to(beFalse())
            expect(RRuleFreq.hourly.isLessThanMinutely).to(beTrue())
            expect(RRuleFreq.secondly.isLessThanSecondly).to(beFalse())
        }

        it("compares") {
            expect(RRuleFreq.monthly).to(beGreaterThan(RRuleFreq.yearly))
            expect(RRuleFreq.weekly).to(beGreaterThan(RRuleFreq.monthly))
            expect(RRuleFreq.daily).to(beGreaterThan(RRuleFreq.weekly))
            expect(RRuleFreq.hourly).to(beGreaterThan(RRuleFreq.daily))
            expect(RRuleFreq.minutely).to(beGreaterThan(RRuleFreq.hourly))
            expect(RRuleFreq.secondly).to(beGreaterThan(RRuleFreq.minutely))
        }
    }
}
