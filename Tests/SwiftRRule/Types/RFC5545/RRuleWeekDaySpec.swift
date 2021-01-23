//
//  RRuleWeekDaySpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class RRuleWeekDaySpec: QuickSpec {
    override func spec() {
        it("initializes from raw value") {
            expect(RRuleWeekDay.init(rawValue: 0)!).to(equal(.monday()))
            expect(RRuleWeekDay.init(rawValue: 1)!).to(equal(.tuesday()))
            expect(RRuleWeekDay.init(rawValue: 2)!).to(equal(.wednesday()))
            expect(RRuleWeekDay.init(rawValue: 3)!).to(equal(.thursday()))
            expect(RRuleWeekDay.init(rawValue: 4)!).to(equal(.friday()))
            expect(RRuleWeekDay.init(rawValue: 5)!).to(equal(.saturday()))
            expect(RRuleWeekDay.init(rawValue: 6)!).to(equal(.sunday()))
        }

        it("compares") {
            expect(RRuleWeekDay.tuesday()).to(beGreaterThan(.monday()))
            expect(RRuleWeekDay.wednesday()).to(beGreaterThan(.tuesday()))
            expect(RRuleWeekDay.thursday()).to(beGreaterThan(.wednesday()))
            expect(RRuleWeekDay.friday()).to(beGreaterThan(.thursday()))
            expect(RRuleWeekDay.saturday()).to(beGreaterThan(.friday()))
            expect(RRuleWeekDay.sunday()).to(beGreaterThan(.saturday()))
        }

        it("allows conversion to same day, but 'nth'") {
            expect(RRuleWeekDay.monday().nth(-1)).to(equal(.monday(n: -1)))
            expect(RRuleWeekDay.tuesday().nth(-1)).to(equal(.tuesday(n: -1)))
            expect(RRuleWeekDay.wednesday().nth(-1)).to(equal(.wednesday(n: -1)))
            expect(RRuleWeekDay.thursday().nth(-1)).to(equal(.thursday(n: -1)))
            expect(RRuleWeekDay.friday().nth(-1)).to(equal(.friday(n: -1)))
            expect(RRuleWeekDay.saturday().nth(-1)).to(equal(.saturday(n: -1)))
            expect(RRuleWeekDay.sunday().nth(-1)).to(equal(.sunday(n: -1)))
        }

        it("hashes including n") {
            var
                hasher: Hasher = Hasher(),
                nHasher: Hasher = Hasher()

            hasher.combine(RRuleWeekDay.monday())
            nHasher.combine(RRuleWeekDay.monday(n: 3))

            expect(hasher.finalize()).notTo(equal(nHasher.finalize()))
        }

        it("exposes a raw value") {
            expect(RRuleWeekDay.monday().rawValue).to(equal(0))
            expect(RRuleWeekDay.tuesday().rawValue).to(equal(1))
            expect(RRuleWeekDay.wednesday().rawValue).to(equal(2))
            expect(RRuleWeekDay.thursday().rawValue).to(equal(3))
            expect(RRuleWeekDay.friday().rawValue).to(equal(4))
            expect(RRuleWeekDay.saturday().rawValue).to(equal(5))
            expect(RRuleWeekDay.sunday().rawValue).to(equal(6))
        }

        it("interoperates with WeekDay") {
            expect(RRuleWeekDay.monday().weekDay).to(equal(.monday))
            expect(RRuleWeekDay.tuesday().weekDay).to(equal(.tuesday))
            expect(RRuleWeekDay.wednesday().weekDay).to(equal(.wednesday))
            expect(RRuleWeekDay.thursday().weekDay).to(equal(.thursday))
            expect(RRuleWeekDay.friday().weekDay).to(equal(.friday))
            expect(RRuleWeekDay.saturday().weekDay).to(equal(.saturday))
            expect(RRuleWeekDay.sunday().weekDay).to(equal(.sunday))
        }

        describe("partitioning") {
            context("when freq is weekly or more") {
                it("ignores n") {
                    expect(
                        RRuleWeekDay.monday(n: -3).partitioned(freq: .weekly)
                    ).to(equal([.value(0)]))
                }
            }

            context("when freq is less than weekly, n is present") {
                it("honors n") {
                    expect(
                        RRuleWeekDay.monday(n: -3).partitioned(freq: .monthly)
                    ).to(equal([.ordinal(0, n: -3)]))
                }
            }

            context("when freq is less than weekly, n is absent") {
                it("honors n") {
                    expect(
                        RRuleWeekDay.monday().partitioned(freq: .monthly)
                    ).to(equal([.value(0)]))
                }
            }
        }
    }
}
