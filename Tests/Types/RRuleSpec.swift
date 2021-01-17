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

        describe("Recurrable") {
            var rfcRRule: RFCRRule {
                let
                    whence = RFCRRuleWhence(),
                    parameters = RFCRRuleParameters(dtstart: whence.dtstart),
                    details = RFCRRuleDetails(
                        freq: parameters.freq,
                        dtstart: whence.dtstart
                    )

                return RFCRRule(whence, parameters, details)
            }

            describe("initializing with RRule") {
                it("does not normally throw") {
                    expect {
                        try Recurrable(rfcRRule)
                    }.notTo(throwError())
                }
            }

            describe("initializing with RFCRRule") {
                it("does not normally throw") {
                    expect {
                        try Recurrable(rfcRRule)
                    }.notTo(throwError())
                }
            }
        }
    }
}
