//
//  RRuleMonthSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class RRuleMonthSpec: QuickSpec {
    override func spec() {
        it("compares values") {
            expect(RRuleMonth.february).to(beGreaterThan(.january))
            expect(RRuleMonth.march).to(beGreaterThan(.february))
            expect(RRuleMonth.april).to(beGreaterThan(.march))
            expect(RRuleMonth.may).to(beGreaterThan(.april))
            expect(RRuleMonth.june).to(beGreaterThan(.may))
            expect(RRuleMonth.july).to(beGreaterThan(.june))
            expect(RRuleMonth.august).to(beGreaterThan(.july))
            expect(RRuleMonth.september).to(beGreaterThan(.august))
            expect(RRuleMonth.october).to(beGreaterThan(.september))
            expect(RRuleMonth.november).to(beGreaterThan(.october))
            expect(RRuleMonth.december).to(beGreaterThan(.november))
        }

        it("interoperates with Month") {
            expect(RRuleMonth.january.month).to(equal(.january))
            expect(RRuleMonth.february.month).to(equal(.february))
            expect(RRuleMonth.march.month).to(equal(.march))
            expect(RRuleMonth.april.month).to(equal(.april))
            expect(RRuleMonth.may.month).to(equal(.may))
            expect(RRuleMonth.june.month).to(equal(.june))
            expect(RRuleMonth.july.month).to(equal(.july))
            expect(RRuleMonth.august.month).to(equal(.august))
            expect(RRuleMonth.september.month).to(equal(.september))
            expect(RRuleMonth.october.month).to(equal(.october))
            expect(RRuleMonth.november.month).to(equal(.november))
            expect(RRuleMonth.december.month).to(equal(.december))
        }

        it("flattens") {
            expect(RRuleMonth.january.flattened()).to(equal([1]))
            expect(RRuleMonth.february.flattened()).to(equal([2]))
            expect(RRuleMonth.march.flattened()).to(equal([3]))
        }
    }
}
