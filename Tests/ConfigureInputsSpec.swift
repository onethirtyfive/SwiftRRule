//
//  ConfigureInputsSpec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/2/21.
//

import Quick
import Nimble
import Foundation
import SwiftDate

@testable import BLRRuleSwift

class ConfigureInputsSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ _: Quick.Configuration) {
        // MARK: - shared: configures without throwing
        sharedExamples("configures without throwing") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            let inputs = sharedExampleContext()["inputs"] as! Inputs

            var configuration: BLRRuleSwift.Configuration {
                get { try! ConfigureInputs(inputs).run() }
            }

            it("does not throw") {
                expect { configuration }.notTo(throwError())
            }
        }

        // MARK: shared: does not violate invariants
        sharedExamples("does not violate invariants") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            let inputs = sharedExampleContext()["inputs"] as! Inputs
            let inputOutset = inputs.outset
            let rrule = inputs.rrule

            var configuration: BLRRuleSwift.Configuration {
                get { try! ConfigureInputs(inputs).run() }
            }
            let configuredOutset = configuration.outset
            let recurrenceCriteria = configuration.recurrenceCriteria

            describe("outset") {
                it("defaults dtstart to current system time") {
                    let timeInterval = inputOutset.dtstart.date.timeIntervalSince1970

                    expect(
                        configuredOutset.dtstart.timeIntervalSince1970
                    ).to(beLessThanOrEqualTo(timeInterval))
                    expect(
                        configuredOutset.dtstart.timeIntervalSince1970
                    ).to(beCloseTo(timeInterval, within: 1))
                }

                it("rounds down dtstart") {
                    let timeInterval = inputOutset.dtstart.timeIntervalSince1970
                    let remainder = timeInterval.truncatingRemainder(dividingBy: 1)

                    expect(
                        configuredOutset.dtstart.timeIntervalSince1970
                    ).to(beCloseTo(timeInterval - remainder, within: 0.001))
                }

                it("passes tzid unchanged to configuration") {
                    // tzid is optional, and equal() matcher fails on nil
                    if inputOutset.tzid == nil {
                        expect(configuredOutset.tzid).to(beNil())
                    } else {
                        expect(configuredOutset.tzid).to(equal(inputOutset.tzid))
                    }
                }
            }

            describe("rrule") {
                it("passes freq unchanged to configuration") {
                    expect(recurrenceCriteria.freq).to(equal(rrule.freq))
                }

                it("passes interval unchanged to configuration") {
                    expect(recurrenceCriteria.interval).to(equal(rrule.interval))
                }

                it("passes wkst unchanged to configuration") {
                    expect(recurrenceCriteria.wkst).to(equal(rrule.wkst))
                }

                it("passes count unchanged to configuration") {
                    // count is optional, and equal() matcher fails on nil
                    if rrule.count == nil {
                        expect(recurrenceCriteria.count).to(beNil())
                    } else {
                        expect(recurrenceCriteria.count).to(equal(rrule.count))
                    }
                }

                it("passes until unchanged to configuration") {
                    // until is optional, and equal() matcher fails on nil
                    if rrule.until == nil {
                        expect(recurrenceCriteria.until).to(beNil())
                    } else {
                        expect(recurrenceCriteria.until).to(equal(rrule.until))
                    }
                }
            }
        }

        // MARK: shared: partitions weekday using frequency
        sharedExamples("partitions weekday using frequency") {
            (sharedExampleContext: @escaping SharedExampleContext) in

            // context-inherited inputs inherited from calling example
            let inputs = sharedExampleContext()["inputs"] as! Inputs
            let inputOutset = inputs.outset
            let rrule = inputs.rrule

            func onlyWeekDay(_ from: Many<BimodalWeekDay>) -> Many<RFCWeekDay> {
                Many(
                    from.map { (bimodalWeekDay: BimodalWeekDay) -> RFCWeekDay? in
                        switch bimodalWeekDay {
                        case .each(let weekDay): return weekDay
                        case .eachN(_): return nil
                        }
                    }.compactMap { $0 }
                )
            }

            func onlyNWeekDay(_ from: Many<BimodalWeekDay>) -> Many<RFCNWeekDay> {
                Many(
                    from.map { (bimodalWeekDay: BimodalWeekDay) -> RFCNWeekDay? in
                        switch bimodalWeekDay {
                        case .eachN(let nWeekDay): return .some(nWeekDay)
                        case .each: return .none
                        }
                    }.compactMap{ $0 }
                )
            }

            context("when as or less frequent than monthly") {
                var rrule: RFCRRule{
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .yearly
                        return rrule
                    }
                }
                let inputs = Inputs(inputOutset, rrule)

                var configuration: BLRRuleSwift.Configuration {
                    get { try! ConfigureInputs(inputs).run() }
                }
                let recurrenceCriteria = configuration.recurrenceCriteria
                let configuredManyWeekDay = recurrenceCriteria.manyWeekDay
                let configuredManyNWeekDay = recurrenceCriteria.manyNWeekDay

                it("configures weekdays correctly") {
                    switch rrule.byweekday {
                    case .many(let manyBimodalWeekDay):
                        expect(configuredManyWeekDay).to(equal(onlyWeekDay(manyBimodalWeekDay)))
                        expect(configuredManyNWeekDay).to(equal(onlyNWeekDay(manyBimodalWeekDay)))
                    case .one(let bimodalWeekDay):
                        switch bimodalWeekDay {
                        case .each(let weekDay):
                            expect(configuredManyWeekDay).to(equal([weekDay]))
                        case .eachN(let nWeekDay):
                            expect(configuredManyNWeekDay).to(equal([nWeekDay]))
                        }
                    case .none:
                        expect(configuredManyNWeekDay).to(beEmpty())
                        expect(configuredManyNWeekDay).to(beEmpty())
                    }
                }
            }

            context("when as or more frequent than weekly") {
                var rrule: RFCRRule{
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .daily
                        return rrule
                    }
                }
                let inputs = Inputs(inputOutset, rrule)

                var configuration: BLRRuleSwift.Configuration {
                    get { try! ConfigureInputs(inputs).run() }
                }
                let recurrenceCriteria = configuration.recurrenceCriteria
                let manyWeekDay = recurrenceCriteria.manyWeekDay
                let manyNWeekDay = recurrenceCriteria.manyWeekDay

                it("configures weekdays correctly") {
                    switch rrule.byweekday {
                    case .many(let manyBimodalWeekDay):
                        let manyAsWeekDay =
                            Many(onlyNWeekDay(manyBimodalWeekDay).map { $0.toRFCWeekDay() })

                        expect(manyWeekDay).to(
                            equal(onlyWeekDay(manyBimodalWeekDay).union(manyAsWeekDay))
                        )
                    case .one(let bimodalWeekDay):
                        switch bimodalWeekDay {
                        case .each(let weekDay):
                            expect(manyWeekDay).to(equal([weekDay]))
                        case .eachN(let nWeekDay):
                            expect(manyWeekDay).to(equal([nWeekDay.toRFCWeekDay()]))
                        }
                    case .none:
                        expect(manyWeekDay).to(beEmpty())
                        expect(manyNWeekDay).to(beEmpty())
                    }

                    expect(recurrenceCriteria.manyNWeekDay).to(beEmpty())
                }
            }
        }
    }
}

// MARK: -

class ConfiguratorSpec: QuickSpec {
    override func spec() {
        let epoch: Date = "2021-01-01T00:00:00.815479Z".toDate()!.date

        // MARK: - defaulting configuration's reccurence criteria
        describe("defaulting configuration's reccurence criteria") {
            let outset = RFCOutset(dtstart: epoch, tzid: nil)

            let rrule = RFCRRule(
                bymonth: .none,
                bymonthday: .many([]),
                byweekday: .none,
                byyearday: .many([]),
                byweekno: .many([])
            )

            // MARK: on yearly frequency
            describe("on yearly frequency") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .yearly
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }

                let configuration = try! ConfigureInputs(inputs).run()
                let recurrenceCriteria = configuration.recurrenceCriteria

                it("sets month to start date's") {
                    // SwiftDate's Month is zero-indexed; Date's is one-indexed.
                    let epochMonth = outset.dtstart.date.month
                    let month = Month(rawValue: epochMonth - 1)!
                    expect(recurrenceCriteria.manyMonth).to(equal([month]))
                }

                it("sets manyMonthday to array containing start date's monthday") {
                    let epochDay = outset.dtstart.date.day
                    expect(recurrenceCriteria.manyMonthday).to(equal([epochDay]))
                }

                it("does not set manyWeekDay") {
                    expect(recurrenceCriteria.manyWeekDay).to(beEmpty())
                }

                context("when bymonth has cardinality of one") {
                    var rrule: RFCRRule {
                        get {
                            var rrule = rrule // inherit from outer scope
                            rrule.bymonth = .one(.april)
                            return rrule
                        }
                    }
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                }

                context("when bymonth has cardinality of many") {
                    var rrule: RFCRRule {
                        get {
                            var rrule = rrule // inherit from outer scope
                            rrule.bymonth = .many([.april, .december])
                            return rrule
                        }
                    }
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                }
            }

            // MARK: on monthly frequency
            describe("on monthly frequency") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .monthly
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }

                let configuration = try! ConfigureInputs(inputs).run()
                let recurrenceCriteria = configuration.recurrenceCriteria

                it("does not set manyMonth") {
                    expect(recurrenceCriteria.manyMonth).to(beEmpty())
                }

                it("sets manyMonthday to array containing start date's day") {
                    let epochDay = outset.dtstart.date.day
                    expect(recurrenceCriteria.manyMonthday).to(equal([epochDay]))
                }

                it("does not set manyWeekDay") {
                    expect(recurrenceCriteria.manyWeekDay).to(beEmpty())
                }
            }

            // MARK: on weekly frequency
            describe("on weekly frequency") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .weekly
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }

                let configuration = try! ConfigureInputs(inputs).run()
                let recurrenceCriteria = configuration.recurrenceCriteria

                it("does not set manyMonth") {
                    expect(recurrenceCriteria.manyMonth).to(beEmpty())
                }

                it("does not set manyMonthDay") {
                    expect(recurrenceCriteria.manyMonthday).to(beEmpty())
                }

                it("sets manyWeekDay to array containing start date's month") {
                    let epochWeekday = outset.dtstart.date.weekday
                    let weekDay = WeekDay(rawValue: epochWeekday)!.toRFCWeekDay()
                    expect(recurrenceCriteria.manyWeekDay).to(equal([weekDay]))
                }
            }

            // MARK: on other frequency
            describe("on other frequency") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.freq = .daily
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
            }

            context("when byweekno has cardinality one") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule
                        rrule.byweekno = .one(0)
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
            }

            context("when bymonthday has cardinality one") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.bymonthday = .one(0)
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
            }

            context("when byweekday has cardinality none") {
                var rrule: RFCRRule {
                    get {
                        var rrule = rrule // inherit from outer scope
                        rrule.byweekday = .none
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
            }
        }

        // MARK: byweekday
        describe("byweekday") {
            let outset = RFCOutset(dtstart: epoch, tzid: nil)

            describe("only 'each' type in collection") {
                context("with cardinality many") {
                    let rrule = RFCRRule(
                        byweekday: .many([.each(.monday), .each(.tuesday)])
                    )
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                    itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
                }

                context("with cardinality one") {
                    let rrule = RFCRRule(byweekday: .one(.each(.wednesday)))
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                    itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
                }
            }

            describe("only 'each n' type in collection") {
                context("with cardinality many") {
                    let rrule = RFCRRule(
                        byweekday: .many([.eachN(.monday(2)), .eachN(.tuesday(1))])
                    )
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                    itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
                }

                context("with cardinality one") {
                    let rrule = RFCRRule(
                        byweekday: .one(.eachN(.wednesday(4)))
                    )
                    let inputs = Inputs(outset, rrule)

                    itBehavesLike("configures without throwing") { ["inputs": inputs] }
                    itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                    itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
                }
            }

            context("with cardinality none") {
                let rrule = RFCRRule(byweekday: .none)
                let inputs = Inputs(outset, rrule)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
            }

            describe("mixed 'each'/'each n' type in collection (cardinality many)") {
                var rruleByweekdayMixedCardinalityMany: RFCRRule{
                    get {
                        var rrule = RFCRRule()
                        rrule.byweekday = .many([.each(.friday), .eachN(.monday(2))])
                        return rrule
                    }
                }
                let inputs = Inputs(outset, rruleByweekdayMixedCardinalityMany)

                itBehavesLike("configures without throwing") { ["inputs": inputs] }
                itBehavesLike("does not violate invariants") { ["inputs": inputs] }
                itBehavesLike("partitions weekday using frequency") { ["inputs": inputs] }
            }
        }
    }
}
