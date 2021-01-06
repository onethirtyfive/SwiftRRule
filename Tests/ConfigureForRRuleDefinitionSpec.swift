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
        sharedExamples("configures without throwing an error") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            let rruleDefinition =
                sharedExampleContext()["rruleDefinition"] as! RRuleDefinition

            var configuration: BLRRuleSwift.Configuration {
                get {
                    try! ConfigureForRRuleDefinition(rruleDefinition).run()
                }
            }

            it("does not throw") {
                expect {configuration}.notTo(throwError())
            }
        }

        sharedExamples("honors configuration process invariants") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            // context-inherited inputs inherited from calling example
            let rruleDefinition =
                sharedExampleContext()["rruleDefinition"] as! RRuleDefinition
            let outset = rruleDefinition.outset
            let rrule = rruleDefinition.rrule

            // configuration calculated here based on context-inherited inputs
            var configuration: BLRRuleSwift.Configuration {
                get { try! ConfigureForRRuleDefinition(rruleDefinition).run() }
            }
            let configuredOutset: RFCOutset = configuration.outset
            let configuredRecurrenceCriteria: RecurrenceCriteria =
                configuration.recurrenceCriteria

            describe("outset") {
                it("rounds down dtstart") {
                    let timeInterval = outset.dtstart.timeIntervalSince1970
                    let remainder =
                        timeInterval.truncatingRemainder(dividingBy: 1)

                    expect {
                        configuredOutset.dtstart.timeIntervalSince1970
                    }.to(
                        beCloseTo(timeInterval - remainder, within: 0.001)
                    )
                }

                it("passes tzid unchanged to configuration") {
                    // tzid is optional, and equal() matcher fails on nil
                    if outset.tzid == nil {
                        expect(configuredOutset.tzid).to(beNil())
                    } else {
                        expect(configuredOutset.tzid).to(equal(outset.tzid))
                    }
                }
            }

            describe("rrule") {
                it("passes freq unchanged to configuration") {
                    expect(
                        configuredRecurrenceCriteria.freq
                    ).to(equal(rrule.freq))
                }

                it("passes interval unchanged to configuration") {
                    expect(
                        configuredRecurrenceCriteria.interval
                    ).to(equal(rrule.interval))
                }

                it("passes wkst unchanged to configuration") {
                    expect(
                        configuredRecurrenceCriteria.wkst
                    ).to(equal(rrule.wkst))
                }

                it("passes count unchanged to configuration") {
                    // count is optional, and equal() matcher fails on nil
                    if rrule.count == nil {
                        expect {
                            configuredRecurrenceCriteria.count
                        }.to(beNil())
                    } else {
                        expect(
                            configuredRecurrenceCriteria.count
                        ).to(equal(rrule.count))
                    }
                }

                it("passes until unchanged to configuration") {
                    // until is optional, and equal() matcher fails on nil
                    if rrule.until == nil {
                        expect(configuredRecurrenceCriteria.until).to(beNil())
                    } else {
                        expect(configuredRecurrenceCriteria.until).to(
                            equal(rrule.until)
                        )
                    }
                }
            }
        }

        enum TestingError: Error {
            case noneCardinalityInvalid
        }

        sharedExamples("considers frequency when partitioning weekdays") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            // context-inherited inputs inherited from calling example
            let rruleDefinition =
                sharedExampleContext()["rruleDefinition"] as! RRuleDefinition
            let outset = rruleDefinition.outset
            let rrule = rruleDefinition.rrule

            // configuration calculated here based on context-inherited inputs
            var configuration: BLRRuleSwift.Configuration {
                get { try! ConfigureForRRuleDefinition(rruleDefinition).run() }
            }

            context("when as or less frequent than monthly") {
                var rruleAsOrLessFrequentThanMonthly: RFCRRule{
                    get {
                        var rrule = rrule
                        rrule.freq = .yearly
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleAsOrLessFrequentThanMonthly)

                var configuration: BLRRuleSwift.Configuration {
                    get {
                        try! ConfigureForRRuleDefinition(rruleDefinition).run()
                    }
                }

                let configuredRecurrenceCriteria: RecurrenceCriteria =
                    configuration.recurrenceCriteria

                let configuredManyWeekDay = configuredRecurrenceCriteria.manyWeekDay
                let configuredManyNWeekDay = configuredRecurrenceCriteria.manyNWeekDay

                it("configures weekdays correctly") {
                    switch rrule.byweekday {
                    case .many(let manyBimodalWeekDay):
                        let allWeekDay: Many<RFCWeekDay> =
                            Many(
                                manyBimodalWeekDay.map { (bwd: BimodalWeekDay) -> RFCWeekDay? in
                                    switch bwd {
                                    case .each(let weekDay):
                                        return weekDay
                                    case .eachNth(_):
                                        return nil
                                    }
                                }.compactMap { $0 }
                            )

                        expect(configuredManyWeekDay).to(equal(allWeekDay))

                        let allNWeekDay: Many<RFCNthWeekDay> =
                            Many(
                                manyBimodalWeekDay.map { (bwd: BimodalWeekDay) -> RFCNthWeekDay? in
                                    switch bwd {
                                    case .eachNth(let nthWeekDay):
                                        return .some(nthWeekDay)
                                    case .each:
                                        return .none
                                    }
                                }.compactMap { $0 }
                            )

                        expect(configuredManyNWeekDay).to(equal(allNWeekDay))
                    case .one(let bimodalWeekDay):
                        switch bimodalWeekDay {
                        case .each(let weekDay):
                            expect(configuredManyWeekDay).to(equal([weekDay]))
                        case .eachNth(let nthWeekDay):
                            expect(configuredManyNWeekDay).to(equal([nthWeekDay]))
                        }
                    case .none:
                        throw TestingError.noneCardinalityInvalid
                    }
                }
            }

            context("when as or more frequent than weekly") {
                var rruleAsOrMoreFrequentlyThanWeekly: RFCRRule{
                    get {
                        var rrule = rruleDefinition.rrule
                        rrule.freq = .daily
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleAsOrMoreFrequentlyThanWeekly)

                var configuration: BLRRuleSwift.Configuration {
                    get {
                        try! ConfigureForRRuleDefinition(rruleDefinition).run()
                    }
                }

                let configuredRecurrenceCriteria: RecurrenceCriteria =
                    configuration.recurrenceCriteria

                let configuredManyWeekDay = configuredRecurrenceCriteria.manyWeekDay

                it("configures weekdays correctly") {
                    switch rrule.byweekday {
                    case .many(let manyBimodalWeekDay):
                        let allWeekDay: Many<RFCWeekDay> =
                            Many(
                                manyBimodalWeekDay.map { (bwd: BimodalWeekDay) -> RFCWeekDay? in
                                    switch bwd {
                                    case .each(let weekDay):
                                        return .some(weekDay)
                                    case .eachNth(_):
                                        return .none
                                    }
                                }.compactMap { $0 }
                            )

                        let allNthWeekDayAsWeekDay: Many<RFCWeekDay> =
                            Many(
                                manyBimodalWeekDay.map { (bwd: BimodalWeekDay) -> RFCNthWeekDay? in
                                    switch bwd {
                                    case .eachNth(let nthWeekDay):
                                        return .some(nthWeekDay)
                                    case .each:
                                        return .none
                                    }
                                }.compactMap { (nthWeekDay: RFCNthWeekDay?) -> RFCWeekDay? in
                                    nthWeekDay?.toRFCWeekDay()
                                }
                            )
                        expect(configuredManyWeekDay).to(
                            equal(allWeekDay.union(allNthWeekDayAsWeekDay))
                        )
                    case .one(let bimodalWeekDay):
                        switch bimodalWeekDay {
                        case .each(let weekDay):
                            expect(configuredManyWeekDay).to(equal([weekDay]))
                        case .eachNth(let nthWeekDay):
                            expect(configuredManyWeekDay).to(
                                equal([nthWeekDay.toRFCWeekDay()])
                            )
                        }
                    case .none:
                        throw TestingError.noneCardinalityInvalid
                    }

                    expect {
                        configuredRecurrenceCriteria.manyNWeekDay
                    }.to(beEmpty())
                }
            }
        }
    }
}

class ConfiguratorSpec: QuickSpec {
    override func spec() {
        let epoch: Date = "2021-01-01T00:00:00.815479Z".toDate()!.date

        describe("defaulting recurrence criteria") {
            let outset = RFCOutset(dtstart: epoch, tzid: nil)

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

                it("sets month to start date's") {
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
                    var rruleDefaultingYearlyByMonthCardinalityOne: RFCRRule {
                        get {
                            var rrule = rruleDefaultingYearly
                            rrule.bymonth = .one(.april)
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(
                            outset,
                            rruleDefaultingYearlyByMonthCardinalityOne
                        )

                    itBehavesLike("configures without throwing an error") {
                        return ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

                context("when bymonth has cardinality of many") {
                    var rruleDefaultingYearlyByMonthCardinalityMany: RFCRRule {
                        get {
                            var rrule = rruleDefaultingYearly
                            rrule.bymonth = .many([.april, .december])
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(
                            outset,
                            rruleDefaultingYearlyByMonthCardinalityMany
                        )

                    itBehavesLike("configures without throwing an error") {
                        return ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }
            }

            describe("on monthly frequency") {
                var rruleDefaultingMonthly: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.freq = .monthly
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingMonthly)

                var configuredRecurrenceCriteria: RecurrenceCriteria {
                    get {
                        let configuration =
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        return configuration.recurrenceCriteria
                    }
                }

                it("does not set manyMonth") {
                    expect(
                        configuredRecurrenceCriteria.manyMonth
                    ).to(beEmpty())
                }

                it("sets manyMonthday to array containing start date's day") {
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

                itBehavesLike("configures without throwing an error") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }

            describe("on weekly frequency") {
                var rruleDefaultingWeekly: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.freq = .weekly
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingWeekly)

                var configuredRecurrenceCriteria: RecurrenceCriteria {
                    get {
                        let configuration =
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        return configuration.recurrenceCriteria
                    }
                }

                it("does not set manyMonth") {
                    expect(
                        configuredRecurrenceCriteria.manyMonth
                    ).to(beEmpty())
                }

                it("does not set manyMonthDay") {
                    expect(
                        configuredRecurrenceCriteria.manyMonthday
                    ).to(beEmpty())
                }

                it("sets manyWeekDay to array containing start date's month") {
                    let epochWeekday = outset.dtstart.date.weekday
                    let weekDay = WeekDay(rawValue: epochWeekday)!.toRFCWeekDay()
                    expect(
                        configuredRecurrenceCriteria.manyWeekDay
                    ).to(equal([weekDay]))
                }

                itBehavesLike("configures without throwing an error") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }

            describe("on other frequency") {
                var rruleDefaultingDaily: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.freq = .daily
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingDaily)

                itBehavesLike("configures without throwing an error") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }

            context("when byweekno has cardinality one") {
                var rruleDefaultingByweeknoCardinalityOne: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.byweekno = .one(0)
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingByweeknoCardinalityOne)

                itBehavesLike("configures without throwing an error") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }

            context("when bymonthday has cardinality one") {
                var rruleDefaultingBymonthdayCardinalityOne: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.bymonthday = .one(0)
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingBymonthdayCardinalityOne)

                itBehavesLike("configures without throwing an error") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }

            context("when byweekday has cardinality none") {
                var rruleDefaultingBymonthdayCardinalityNone: RFCRRule {
                    get {
                        var rrule = rruleDefaulting
                        rrule.bymonthday = .none
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleDefaultingBymonthdayCardinalityNone)

                itBehavesLike("configures without throwing an error") {
                    ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }
        }

        // TODO: Rework as contexts to check "honors invariants"
        describe("byweekday") {
            let outset = RFCOutset(dtstart: epoch, tzid: nil)

            describe("only 'each' type in collection") {
                context("with cardinality many") {
                    var rruleByweekdayEachOnlyCardinalityMany: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday = .many([.each(.monday), .each(.tuesday)])
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachOnlyCardinalityMany)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(equal([.monday, .tuesday]))

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(beEmpty())
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

                context("with cardinality one") {
                    var rruleByweekdayEachOnlyCardinalityOne: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday = .one(.each(.wednesday))
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachOnlyCardinalityOne)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(equal([.wednesday]))

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(beEmpty())
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

                context("with cardinality none") {
                    var rruleByweekdayEachOnlyCardinalityNone: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday = .none
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachOnlyCardinalityNone)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(beEmpty())

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(beEmpty())
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }
            }

            describe("only 'each nth' type in collection") {
                context("with cardinality many") {
                    var rruleByweekdayEachNthOnlyCardinalityMany: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday =
                                .many([.eachNth(.monday(2)), .eachNth(.tuesday(1))])
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachNthOnlyCardinalityMany)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(beEmpty())

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(equal([.monday(2), .tuesday(1)]))
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("considers frequency when partitioning weekdays") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

                context("with cardinality one") {
                    var rruleByweekdayEachNthOnlyCardinalityOne: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday = .one(.eachNth(.wednesday(4)))
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachNthOnlyCardinalityOne)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(beEmpty())

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(equal([.wednesday((4))]))
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("considers frequency when partitioning weekdays") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }

                context("with cardinality none") {
                    var rruleByweekdayEachNthOnlyCardinalityNone: RFCRRule{
                        get {
                            var rrule = RFCRRule()
                            rrule.byweekday = .none
                            return rrule
                        }
                    }

                    let rruleDefinition =
                        RRuleDefinition(outset, rruleByweekdayEachNthOnlyCardinalityNone)

                    var configuration: BLRRuleSwift.Configuration {
                        get {
                            try! ConfigureForRRuleDefinition(rruleDefinition).run()
                        }
                    }

                    let configuredRecurrenceCriteria: RecurrenceCriteria =
                        configuration.recurrenceCriteria

                    it("configures weekdays correctly") {
                        expect {
                            configuredRecurrenceCriteria.manyWeekDay
                        }.to(beEmpty())

                        expect {
                            configuredRecurrenceCriteria.manyNWeekDay
                        }.to(beEmpty())
                    }

                    itBehavesLike("configures without throwing an error") {
                        ["rruleDefinition": rruleDefinition]
                    }

                    itBehavesLike("honors configuration process invariants") {
                        return ["rruleDefinition": rruleDefinition]
                    }
                }
            }

            describe("mixed 'each'/'each nth' type in collection (cardinality many)") {
                var rruleByweekdayMixedCardinalityMany: RFCRRule{
                    get {
                        var rrule = RFCRRule()
                        rrule.byweekday =
                            .many([.each(.friday), .eachNth(.monday(2))])
                        return rrule
                    }
                }

                let rruleDefinition =
                    RRuleDefinition(outset, rruleByweekdayMixedCardinalityMany)

                itBehavesLike("configures without throwing an error") {
                    ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("honors configuration process invariants") {
                    return ["rruleDefinition": rruleDefinition]
                }

                itBehavesLike("considers frequency when partitioning weekdays") {
                    return ["rruleDefinition": rruleDefinition]
                }
            }
        }
    }
}
