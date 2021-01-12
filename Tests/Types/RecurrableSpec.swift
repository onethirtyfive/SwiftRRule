//
//  RecurrableSpec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/11/21.
//

import Foundation
import Quick
import Nimble

@testable import BLRRuleSwift

class RecurrableSpec: QuickSpec {
    override func spec() {
        describe("Recurrable") {
            let rfcRRule = RFCRRule(RFCWhence(), RFCRRuleParameters(), RFCRRuleDetails())

            it("initializes") {
                Recurrable(Whence(), Parameters(), rfcRRule.criteria)
            }
        }
    }
}
