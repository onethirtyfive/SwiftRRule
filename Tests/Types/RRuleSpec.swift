//
//  RRuleSpec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/7/21.
//

import Quick
import Nimble
import Foundation
import SwiftDate

@testable import BLRRuleSwift

class RRuleSpec: QuickSpec {
    override func spec() {
        describe("RRule") {

        }

        describe("NormalRRule") {

        }

        describe("NormalValidRRule") {

        }

        describe("Configuration") {
            var rfcRRule: RFCRRule {
                RFCRRule(RFCWhence(), RFCRRuleParameters(), RFCRRuleDetails())
            }

            describe("initializing with RRule") {
                it("does not normally throw") {
                    expect {
                        try BLRRuleSwift.Configuration(rfcRRule)
                    }.notTo(throwError())
                }
            }

            describe("initializing with RFCRRule") {
                it("does not normally throw") {
                    expect {
                        try BLRRuleSwift.Configuration(rfcRRule)
                    }.notTo(throwError())
                }
            }
        }
    }
}
