//
//  ConfigureForRRuleDefinitionSpec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/2/21.
//

import Quick
import Nimble
import Foundation
import SwiftDate

@testable import BLRRuleSwift

class InputsSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ _: Quick.Configuration) {
        sharedExamples("configures error-free") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            let rruleDefinition =
                sharedExampleContext()["rruleDefinition"] as! RRuleDefinition

            var configuration: BLRRuleSwift.Configuration {
                get {
                    try! ConfigureForRRuleDefinition(rruleDefinition).run()
                }
            }

            it("does not throw") {
                expect {
                    configuration
                }.notTo(throwError())
            }
        }

        sharedExamples("honors configuration process invariants") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            let rruleDefinition =
                sharedExampleContext()["rruleDefinition"] as! RRuleDefinition

            let outsetDtstart = rruleDefinition.outset.dtstart
            let outsetTzid = rruleDefinition.outset.tzid

            var configuration: BLRRuleSwift.Configuration {
                get { try! ConfigureForRRuleDefinition(rruleDefinition).run() }
            }

            var configuredOutset = configuration.outset

            describe("outset") {
                it("rounds down dtstart") {
                    let timeInterval = outsetDtstart.timeIntervalSince1970
                    let remainder =
                        timeInterval.truncatingRemainder(dividingBy: 1)

                    expect {
                        configuredOutset.dtstart.timeIntervalSince1970
                    }.to(
                        beCloseTo(timeInterval - remainder, within: 0.001)
                    )
                }

                it("passes tzid unchanged to configuration") {
                    expect(
                        configuredOutset.tzid
                    ).to(equal(outsetTzid))
                }
            }

            describe("rrule") {
                it("passes freq unchanged to configuration") {

                }

                it("passes interval unchanged to configuration") {

                }

                it("passes wkst unchanged to configuration") {

                }

                it("passes count unchanged to configuration") {

                }

                it("passes until unchanged to configuration") {

                }

                it("preserves interval in configuration") {

                }

                it("keeps wkst value in configuration") {

                }
            }
        }
    }
}

class ConfiguratorSpec: QuickSpec {
    override func spec() {
        let epoch: Date = "2021-01-01T00:00:00.815479Z".toDate()!.date

        describe("defaulting") {
            var outset = RFCOutset(dtstart: epoch, tzid: nil)

            var rruleDefaulting: RFCRRule {
                get {
                    // Exactly these rrule inputs (existentially) trigger defaulting.
                    var rrule = RFCRRule()
                    rrule.bymonth = .none
                    rrule.byweekno = .many([])
                    rrule.byyearday = .many([])
                    rrule.bymonthday = .many([])
                    rrule.byweekday = .none
                    return rrule
                }
            }

            describe("on yearly frequency") {
                var rruleDefaultingYearly: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.freq = .yearly
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingYearly)

                var configuredRecurrenceCriteria: RecurrenceCriteria {
                    get {
                        let configuration =
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        return configuration.recurrenceCriteria
                    }
                }

                fit("sets month to start date's") {
                    // SwiftDate's Month is zero-indexed; Date's is one-indexed.
                    let epochMonth = outset.dtstart.date.month
                    let month = Month(rawValue: epochMonth - 1)!
                    expect(
                        configuredRecurrenceCriteria.manyMonth
                    ).to(equal([month]))
                }

                it("sets manyMonthday to array containing start date's monthday") {
                    let epochDay = outset.dtstart.date.day
                    expect(
                        configuredRecurrenceCriteria.manyMonthday
                    ).to(equal([epochDay]))
                }

                it("does not set manyWeekDay") {
                    expect(
                        configuredRecurrenceCriteria.manyWeekDay
                    ).to(beEmpty())
                }

                context("when bymonth has cardinality of one") {
                    var outsetWithTzid: RFCOutset {
                        get {
                            var outset = outset
                            outset.tzid = .americaLosAngeles
                            return outset
                        }
                    }

                    var rruleDefaultingYearlyByMonthCardinalityOne: RFCRRule {
                        get {
                            var rrule = rruleDefaultingYearly
                            rrule.bymonth = .one(.april)
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(
                            outsetWithTzid,
                            rruleDefaultingYearlyByMonthCardinalityOne
                        )

                    fitBehavesLike("configures error-free") {
                        return ["rruleDefinition": rruleDefinition]
                    }

                    fitBehavesLike("honors configuration process invariants") {
                        outset.tzid = .americaLosAngeles
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

//                context("when bymonth has cardinality of many") {
//                    beforeEach {
//                        rrule.bymonth = .many([.april, .december])
//                    }
//
//                    itBehavesLike("configures error-free") {
//                        ["rruleDefinition": RRuleDefinition(outset, rrule)]
//                    }
//                }
            }

//            describe("on monthly frequency") {
//                beforeEach {
//                    rrule.freq = .monthly
//                }
//
//                it("does not set manyMonth") {
//                    expect(
//                        configuredRecurrenceCriteria.manyMonth
//                    ).to(beEmpty())
//                }
//
//                it("sets manyMonthday to array containing start date's day") {
//                    let epochDay = outset.dtstart.date.day
//                    expect(
//                        configuredRecurrenceCriteria.manyMonthday
//                    ).to(equal([epochDay]))
//                }
//
//                it("does not set manyWeekDay") {
//                    expect(
//                        configuredRecurrenceCriteria.manyWeekDay
//                    ).to(beEmpty())
//                }
//            }
//
//            describe("on weekly frequency") {
//                beforeEach {
//                    rrule.freq = .weekly
//                }
//
//                it("does not set manyMonth") {
//                    expect(
//                        configuredRecurrenceCriteria.manyMonth
//                    ).to(beEmpty())
//                }
//
//                it("does not set manyMonthDay") {
//                    expect(
//                        configuredRecurrenceCriteria.manyMonthday
//                    ).to(beEmpty())
//                }
//
//                it("sets manyWeekDay to array containing start date's month") {
//                    let epochWeekday = outset.dtstart.date.weekday
//                    let weekDay = WeekDay(rawValue: epochWeekday)!.toRFCWeekDay()
//                    expect(
//                        configuredRecurrenceCriteria.manyWeekDay
//                    ).to(equal([weekDay]))
//                }
//            }
//
//            describe("on other frequency") {
//                beforeEach {
//                    rrule.freq = .daily
//                }
//
//                itBehavesLike("configures error-free") {
//                    ["rruleDefinition": RRuleDefinition(outset, rrule)]
//                }
//            }
//
//            context("when byweekno has cardinality is one") {
//                beforeEach {
//                    rrule.byweekno = .one(0)
//                }
//
//                itBehavesLike("configures error-free") {
//                    ["rruleDefinition": RRuleDefinition(outset, rrule)]
//                }
//            }
//
//            context("when bymonthday has cardinality of one") {
//                beforeEach {
//                    rrule.bymonthday = .one(0)
//                }
//
//                itBehavesLike("configures error-free") {
//                    ["rruleDefinition": RRuleDefinition(outset, rrule)]
//                }
//            }
//
//            context("when byweekday has cardinality other than none") {
//                beforeEach {
//                    rrule.byweekday = .one(.each(.monday))
//                }
//
//                itBehavesLike("configures error-free") {
//                    ["rruleDefinition": RRuleDefinition(outset, rrule)]
//                }
//            }
//        }
//
//        describe("tzid") {
//            it("uses a type when provided") {
//                outset.tzid = .americaLosAngeles
//
//            }
//        }
//
//        // TODO: Rework as contexts to check "honors invariants"
//        describe("byweekday") {
//            describe("only each weekday") {
//                it("configures with cardinality one") {
//                    rrule.byweekday = .one(.each(.monday))
//
//                    expect(
//                        configuredRecurrenceCriteria.manyWeekDay
//                    ).to(equal([.monday]))
//                }
//
//                it("configures with cardinality many") {
//                    rrule.byweekday = .many([.each(.monday), .each(.tuesday)])
//
//                    expect(
//                        configuredRecurrenceCriteria.manyWeekDay
//                    ).to(equal([.monday, .tuesday]))
//                }
//            }
//
//            describe("only each nth weekday") {
//                context("when as or less frequent than monthly") {
//                    beforeEach {
//                        rrule.freq = .monthly
//                    }
//
//                    it("configures with cardinality one") {
//                        rrule.byweekday = .one(.eachNth(.monday(3)))
//
//                        expect(
//                            configuredRecurrenceCriteria.manyNWeekDay
//                        ).to(equal([.monday(3)]))
//                    }
//
//                    it("configures with cardinality many") {
//                        rrule.byweekday =
//                            .many([.eachNth(.monday(3)), .eachNth(.monday(1))])
//
//                        expect(
//                            configuredRecurrenceCriteria.manyNWeekDay
//                        ).to(equal([.monday(3), .monday(1)]))
//                    }
//                }
//
//                context("when as or more frequent than weekly") {
//                    beforeEach {
//                        rrule.freq = .weekly
//                    }
//
//                    it("configures with cardinality one") {
//                        rrule.byweekday = .one(.eachNth(.monday(3)))
//
//                        expect(
//                            configuredRecurrenceCriteria.manyWeekDay
//                        ).to(equal([.monday]))
//                    }
//
//                    it("configures with cardinality many") {
//                        rrule.byweekday =
//                            .many([.eachNth(.monday(3)), .eachNth(.monday(1))])
//
//                        expect(
//                            configuredRecurrenceCriteria.manyWeekDay
//                        ).to(equal([.monday, .monday]))
//
//                        expect(
//                            configuredRecurrenceCriteria.manyNWeekDay
//                        ).to(beEmpty())
//                    }
//                }
//            }
//
//            describe("mixed each/nth weekday") {
//                context("when as or less frequent than monthly") {
//                    beforeEach {
//                        rrule.freq = .monthly
//                    }
//
//                    it ("configures mixed weekday/nth-weekday rruleDefinition") {
//                        rrule.byweekday =
//                            .many([.each(.monday), .eachNth(.friday(3))])
//
//                        expect(
//                            configuredRecurrenceCriteria.manyWeekDay
//                        ).to(equal([.monday]))
//
//                        expect(
//                            configuredRecurrenceCriteria.manyNWeekDay
//                        ).to(equal([.friday(3)]))
//                    }
//                }
//
//                context("when as or more frequent than weekly") {
//                    beforeEach {
//                        rrule.freq = .weekly
//                    }
//
//                    it ("configures mixed weekday/nth-weekday rruleDefinition") {
//                        rrule.byweekday =
//                            .many([.each(.monday), .eachNth(.friday(3))])
//
//                        expect(
//                            configuredRecurrenceCriteria.manyWeekDay
//                        ).to(equal([.monday, .friday]))
//
//                        expect(
//                            configuredRecurrenceCriteria.manyNWeekDay
//                        ).to(beEmpty())
//                    }
//                }
//            }
        }
    }
}
