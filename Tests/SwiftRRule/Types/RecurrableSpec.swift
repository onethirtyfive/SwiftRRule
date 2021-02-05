//
//  RecurrableSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

class RecurrableSpec: QuickSpec {
    override func spec() {
        describe("initializing with RRule") {
            context("with normal-valid rrule") {
                var rrule: RRule {
                    let
                        whence = RRuleWhence(),
                        parameters = RRuleParameters(dtstart: whence.dtstart),
                        details = RRuleDetails(
                            freq: parameters.freq,
                            dtstart: whence.dtstart
                        )

                    return RRule(whence, parameters, details)
                }

                it("does not throw") {
                    expect {
                        try Recurrable(rrule)
                    }.notTo(throwError())
                }

                it("exposes all details") {
                    let recurrable = try Recurrable(rrule)

                    expect {
                        let
                            _ = recurrable.byyearday,
                            _ = recurrable.byweekno,
                            _ = recurrable.bysetpos,
                            _ = recurrable.bymonth,
                            _ = recurrable.bymonthday,
                            _ = recurrable.bynmonthday,
                            _ = recurrable.byweekday,
                            _ = recurrable.bynweekday,
                            _ = recurrable.byhour,
                            _ = recurrable.byminute,
                            _ = recurrable.bysecond
                    }.notTo(throwError())
                }
            }

            context("with normal-valid rrule") {
                var rrule: RRule {
                    let
                        whence = RRuleWhence(),
                        parameters = RRuleParameters(dtstart: whence.dtstart),
                        details = RRuleDetails(
                            freq: parameters.freq,
                            dtstart: whence.dtstart,
                            byweekno: Byweekno(.one(0))
                        )

                    return RRule(whence, parameters, details)
                }

                it("throws") {
                    expect {
                        try Recurrable(rrule)
                    }.to(throwError(RRuleDetailValidationError.invalidMember(0)))
                }
            }
        }
    }
}
