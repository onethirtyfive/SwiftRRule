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
            anchoredCriterion = AnchoredCriterion<Number>(.none, anchor: reference.day)

        sharedExamplesForUnanchored("flattens number detail", Criterion<Number>(.none))
        sharedExamplesForUnanchored("flattens month detail", Criterion<Month>(.none))
        sharedExamplesForAnchored("flattens number detail", anchoredCriterion)
    }
}

class CriteriaSpec: QuickSpec {
    override func spec() {
        let reference = "2021-01-01T00:00:00.815479Z".toDate()!.date

        // MARK: Criterion<Number>

        describe("Criterion<Number>") {
            let
                whichMany = Criterion<Number>(.many([1,2,3])),
                whichOne = Criterion<Number>(.one(1)),
                whichNone = Criterion<Number>(.none)

            itBehavesLike("unanchored: flattens number detail") { ["flattenable": whichMany] }
            itBehavesLike("unanchored: flattens number detail") { ["flattenable": whichOne] }
            itBehavesLike("unanchored: flattens number detail") { ["flattenable": whichNone] }
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

        // MARK: AnchoredCriterion<Number> for hour

        describe("AnchoredCriterion<Number>") {
            let
                hour = reference.hour,
                whichMany = AnchoredCriterion<Number>(.many([1,15,-1]), anchor: hour),
                whichOne = AnchoredCriterion<Number>(.one(13), anchor: hour),
                whichNone = AnchoredCriterion<Number>(.none, anchor: hour)

            itBehavesLike("anchored: flattens number detail") {
                [
                    "flattenable": whichMany,
                    "anchor": hour
                ]
            }

            itBehavesLike("anchored: flattens number detail") {
                [
                    "flattenable": whichOne,
                    "anchor": hour
                ]
            }

            itBehavesLike("anchored: flattens number detail") {
                [
                    "flattenable": whichNone,
                    "anchor": hour
                ]
            }
        }

        // MARK: MonthdayCriterion<Number,Number,Number>

        describe("MonthdayCriterion<Number,Number,Number>") {
            context("with many monthday") {
                let criterion = MonthdayCriterion<Number,Number,Number>(.many([1,2,3,-4]))

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyOrdMonthday) = criterion.partitioned
                    expect(manyMonthday).to(equal([1,2,3]))
                    expect(manyOrdMonthday).to(equal([-4]))
                }
            }

            context("with one monthday") {
                let criterion = MonthdayCriterion<Number,Number,Number>(.one(-4))

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyOrdMonthday) = criterion.partitioned
                    expect(manyMonthday).to(beEmpty())
                    expect(manyOrdMonthday).to(equal([-4]))
                }
            }

            context("with none monthday") {
                let criterion = MonthdayCriterion<Number,Number,Number>(.none)

                it("yields correct partitioned weekdays") {
                    let (manyMonthday, manyOrdMonthday) = criterion.partitioned
                    expect(manyMonthday).to(beEmpty())
                    expect(manyOrdMonthday).to(beEmpty())
                }
            }
        }

        // MARK: WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>

        describe("WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay") {
            context("with many weekday") {
                context("ignoring n") {
                    let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>(
                        .many([.each(.monday),.eachN(.tuesday(1))]),
                        ignoreN: true
                    )

                    it("yields correct partitioned weekdays") {
                        let (manyWeekDay, manyOrdWeekDay) = criterion.partitioned
                        expect(manyWeekDay).to(equal([.monday,.tuesday]))
                        expect(manyOrdWeekDay).to(beEmpty())
                    }
                }

                context("not ignoring n") {
                    let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>(
                        .many([.each(.monday),.eachN(.tuesday(1))]),
                        ignoreN: false
                    )

                    it("yields correct partitioned weekdays") {
                        let (manyWeekDay, manyOrdWeekDay) = criterion.partitioned
                        expect(manyWeekDay).to(equal([.monday]))
                        expect(manyOrdWeekDay).to(equal([.tuesday(1)]))
                    }
                }
            }

            context("with one weekday") {
                let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>(
                    .one(.each(.friday)),
                    ignoreN: true
                )

                it("yields correct partitioned weekdays") {
                    let (manyWeekDay, _) = criterion.partitioned
                    expect(manyWeekDay).to(equal([.friday]))
                }
            }

            context("with none weekday") {
                let criterion = WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>(
                    .none, ignoreN: true
                )

                it("yields correct partitioned weekdays") {
                    let (manyWeekDay, manyOrdWeekDay) = criterion.partitioned
                    expect(manyWeekDay).to(beEmpty())
                    expect(manyOrdWeekDay).to(beEmpty())
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
                expect(criteria.normalOrdMonthday).to(beEmpty())
                expect(criteria.normalWeekDay).to(beEmpty())
                expect(criteria.normalOrdWeekDay).to(beEmpty())
            }
        }
    }
}
