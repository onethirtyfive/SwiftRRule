//
//  CriteriaSpec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/11/21.
//

import Foundation
import Quick
import Nimble
import SwiftDate

@testable import BLRRuleSwift

class CriteriaSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Quick.Configuration) {
        func sharedExamplesForUnanchored<T: Flattenable>(_ desc: String, _: T?=nil) {
            sharedExamples("unanchored: \(desc)") { (ctx: @escaping SharedExampleContext) in
                let flattenable = ctx()["flattenable"] as! T

                it("yields correct flattened list") {
                    switch flattenable.detail {
                    case .many(let many):
                        expect(flattenable.flattened).to(equal(many))
                    case .one(let one):
                        expect(flattenable.flattened).to(equal([one]))
                    case .none:
                        expect(flattenable.flattened).to(beEmpty())
                    }
                }
            }
        }

        func sharedExamplesForAnchored<T: Flattenable>(_ desc: String, _: T?=nil) {
            sharedExamples("anchored: \(desc)") { (ctx: @escaping SharedExampleContext) in
                let
                    flattenable = ctx()["flattenable"] as! T,
                    anchor = ctx()["anchor"] as! T.T

                it("yields correct flattened list") {
                    switch flattenable.detail {
                    case .many(let many):
                        expect(flattenable.flattened).to(equal(many))
                    case .one(let one):
                        expect(flattenable.flattened).to(equal([one]))
                    case .none:
                        expect(flattenable.flattened).to(equal([anchor]))
                    }
                }
            }
        }

        let
            reference = "2021-01-01T00:00:00.815479Z".toDate()!.date,
            anchoredCriterion = AnchoredCriterion<Ord>(.none, anchor: reference.day)

        sharedExamplesForUnanchored("flattens ordinal detail", Criterion<Ord>(.none))
        sharedExamplesForUnanchored("flattens month detail", Criterion<Month>(.none))
        sharedExamplesForAnchored("flattens ordinal detail", anchoredCriterion)
    }
}

class CriteriaSpec: QuickSpec {
    override func spec() {
        let reference = "2021-01-01T00:00:00.815479Z".toDate()!.date

        // MARK: Criterion<Ord>

        describe("Criterion<Ord>") {
            let
                whichMany = Criterion<Ord>(.many([1,2,3])),
                whichOne = Criterion<Ord>(.one(1)),
                whichNone = Criterion<Ord>(.none)

            itBehavesLike("unanchored: flattens ordinal detail") { ["flattenable": whichMany] }
            itBehavesLike("unanchored: flattens ordinal detail") { ["flattenable": whichOne] }
            itBehavesLike("unanchored: flattens ordinal detail") { ["flattenable": whichNone] }
        }

        // MARK: Criterion<Month>

        describe("Criterion<Month>") {
            let whichMany = Criterion<Month>(.many([.june, .march]))
            let whichOne = Criterion<Month>(.one(.april))
            let whichNone = Criterion<Month>(.none)

            itBehavesLike("unanchored: flattens month detail") { ["flattenable": whichMany] }
            itBehavesLike("unanchored: flattens month detail") { ["flattenable": whichOne] }
            itBehavesLike("unanchored: flattens month detail") { ["flattenable": whichNone] }
        }

        // MARK: AnchoredCriterion<Ord> for hour

        describe("AnchoredCriterion<Ord>") {
            let
                hour = reference.hour,
                whichMany = AnchoredCriterion<Ord>(.many([1,15,-1]), anchor: hour),
                whichOne = AnchoredCriterion<Ord>(.one(13), anchor: hour),
                whichNone = AnchoredCriterion<Ord>(.none, anchor: hour)

            itBehavesLike("anchored: flattens ordinal detail") {
                [
                    "flattenable": whichMany,
                    "anchor": hour
                ]
            }

            itBehavesLike("anchored: flattens ordinal detail") {
                [
                    "flattenable": whichOne,
                    "anchor": hour
                ]
            }

            itBehavesLike("anchored: flattens ordinal detail") {
                [
                    "flattenable": whichNone,
                    "anchor": hour
                ]
            }
        }

        // MARK: MonthdayCriterion<Ord,Ord,Ord>

        describe("MonthdayCriterion<Ord,Ord,Ord>") {
            context("with many monthday") {
                let criterion = MonthdayCriterion<Ord,Ord,Ord>(.many([1,2,3,-4]))

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyNMonthday) = criterion.partitioned
                    expect(manyMonthday).to(equal([1,2,3]))
                    expect(manyNMonthday).to(equal([-4]))
                }
            }

            context("with one monthday") {
                let criterion = MonthdayCriterion<Ord,Ord,Ord>(.one(-4))

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyNMonthday) = criterion.partitioned
                    expect(manyMonthday).to(beEmpty())
                    expect(manyNMonthday).to(equal([-4]))
                }
            }

            context("with none monthday") {
                let criterion = MonthdayCriterion<Ord,Ord,Ord>(.none)

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyNMonthday) = criterion.partitioned
                    expect(manyMonthday).to(beEmpty())
                    expect(manyNMonthday).to(beEmpty())
                }
            }
        }

        // MARK: WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>

        describe("WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay") {
            context("with many weekday") {
                context("ignoring n") {
                    let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>(
                        .many([.each(.monday),.eachN(.tuesday(1))]),
                        ignoreN: true
                    )

                    it("yields correct partitioned weekdays") {
                        let (manyWeekDay, manyNWeekDay) = criterion.partitioned
                        expect(manyWeekDay).to(equal([.monday,.tuesday]))
                        expect(manyNWeekDay).to(beEmpty())
                    }
                }

                context("not ignoring n") {
                    let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>(
                        .many([.each(.monday),.eachN(.tuesday(1))]),
                        ignoreN: false
                    )

                    it("yields correct partitioned weekdays") {
                        let (manyWeekDay, manyNWeekDay) = criterion.partitioned
                        expect(manyWeekDay).to(equal([.monday]))
                        expect(manyNWeekDay).to(equal([.tuesday(1)]))
                    }
                }
            }

            context("with one weekday") {
                let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>(
                    .one(.each(.friday)),
                    ignoreN: true
                )

                it("yields correct partitioned weekdays") {
                    let (manyWeekDay, _) = criterion.partitioned
                    expect(manyWeekDay).to(equal([.friday]))
                }
            }

            context("with none weekday") {
                let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>(
                    .none, ignoreN: true
                )

                it("yields correct partitioned weekdays") {
                    let (manyWeekDay, manyNWeekDay) = criterion.partitioned
                    expect(manyWeekDay).to(beEmpty())
                    expect(manyNWeekDay).to(beEmpty())
                }
            }
        }

        describe("Criteria") {
            let
                reference = "2021-01-01T00:00:00.815479Z".toDate()!.date,
                rfcRRule =
                    RFCRRule(
                        RFCWhence(reference),
                        RFCRRuleParameters(),
                        RFCRRuleDetails()
                    ),
                configuration = try! BLRRuleSwift.Configuration(rfcRRule),
                criteria = configuration.recurrable.criteria

            it("works") {
                expect(criteria.normalSetpos).to(beEmpty())
                expect(criteria.normalYearday).to(beEmpty())
                expect(criteria.normalWeekno).to(beEmpty())
                expect(criteria.normalMonth).to(equal([.january])) //anchored
                expect(criteria.normalHour).to(equal([0])) // anchored
                expect(criteria.normalMinute).to(equal([0])) // anchored
                expect(criteria.normalSecond).to(equal([0])) // anchored
                expect(criteria.normalMonthday).to(equal([1])) //anchored
                expect(criteria.normalNMonthday).to(beEmpty())
                expect(criteria.normalWeekDay).to(beEmpty())
                expect(criteria.normalNWeekDay).to(beEmpty())
            }
        }
    }
}
