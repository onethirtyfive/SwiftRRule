//
//  RFC5545Spec.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/10/21.
//

import Foundation
import Quick
import Nimble
import SwiftDate

@testable import BLRRuleSwift

class RFC5545Spec: QuickSpec {
    override func spec() {
        describe("RFCFrequency") {
            it("knows if its frequency is daily or more") {
                expect(RFCFrequency.daily.isDailyOrLessFrequent).to(beTrue())
                expect(RFCFrequency.yearly.isDailyOrLessFrequent).to(beTrue())
                expect(RFCFrequency.hourly.isDailyOrLessFrequent).to(beFalse())
            }

            describe("comparison") {
                it("works") {
                    expect(RFCFrequency.monthly).to(beGreaterThan(RFCFrequency.yearly))
                    expect(RFCFrequency.weekly).to(beGreaterThan(RFCFrequency.monthly))
                    expect(RFCFrequency.daily).to(beGreaterThan(RFCFrequency.weekly))
                    expect(RFCFrequency.hourly).to(beGreaterThan(RFCFrequency.daily))
                    expect(RFCFrequency.minutely).to(beGreaterThan(RFCFrequency.hourly))
                    expect(RFCFrequency.secondly).to(beGreaterThan(RFCFrequency.minutely))
                }
            }
        }

        describe("RFCWeekDay") {
            describe("comparison") {
                it("works") {
                    expect(RFCWeekDay.tuesday).to(beGreaterThan(.monday))
                    expect(RFCWeekDay.wednesday).to(beGreaterThan(.tuesday))
                    expect(RFCWeekDay.thursday).to(beGreaterThan(.wednesday))
                    expect(RFCWeekDay.friday).to(beGreaterThan(.thursday))
                    expect(RFCWeekDay.saturday).to(beGreaterThan(.friday))
                    expect(RFCWeekDay.sunday).to(beGreaterThan(.saturday))
                }
            }

            describe("WeekDay interoperability") {
                it("works") {
                    expect(RFCWeekDay.monday.weekDay).to(equal(WeekDay.monday))
                    expect(RFCWeekDay.tuesday.weekDay).to(equal(WeekDay.tuesday))
                    expect(RFCWeekDay.wednesday.weekDay).to(equal(WeekDay.wednesday))
                    expect(RFCWeekDay.thursday.weekDay).to(equal(WeekDay.thursday))
                    expect(RFCWeekDay.friday.weekDay).to(equal(WeekDay.friday))
                    expect(RFCWeekDay.saturday.weekDay).to(equal(WeekDay.saturday))
                    expect(RFCWeekDay.sunday.weekDay).to(equal(WeekDay.sunday))
                }
            }
        }

        describe("RFCOrdWeekDay") {
            describe("hashing") {
                it("works") {
                    var
                        weekDayHasher: Hasher = Hasher(),
                        ordWeekDayHasher: Hasher = Hasher()

                    weekDayHasher.combine(RFCWeekDay.monday)
                    ordWeekDayHasher.combine(RFCOrdWeekDay.monday(3))

                    expect(
                        weekDayHasher.finalize()
                    ).notTo(equal(ordWeekDayHasher.finalize()))
                }
            }

            describe("comparison") {
                it("works") {
                    // n-weekday comparison simply requires
                    expect(RFCOrdWeekDay.tuesday(-1)).to(beGreaterThan(.monday(1)))
                    expect(RFCOrdWeekDay.wednesday(1)).to(beGreaterThan(.tuesday(-1)))
                    expect(RFCOrdWeekDay.thursday(1)).to(beGreaterThan(.wednesday(1)))
                    expect(RFCOrdWeekDay.friday(1)).to(beGreaterThan(.thursday(1)))
                    expect(RFCOrdWeekDay.saturday(0)).to(beGreaterThan(.friday(0)))
                    expect(RFCOrdWeekDay.sunday(-1)).to(beGreaterThan(.saturday(-1)))
                }
            }

            describe("RFCWeekDay interoperability") {
                it("works") {
                    expect(RFCOrdWeekDay.monday(1).rfcWeekDay).to(equal(RFCWeekDay.monday))
                    expect(RFCOrdWeekDay.tuesday(1).rfcWeekDay).to(equal(RFCWeekDay.tuesday))
                    expect(RFCOrdWeekDay.wednesday(1).rfcWeekDay).to(equal(RFCWeekDay.wednesday))
                    expect(RFCOrdWeekDay.thursday(1).rfcWeekDay).to(equal(RFCWeekDay.thursday))
                    expect(RFCOrdWeekDay.friday(1).rfcWeekDay).to(equal(RFCWeekDay.friday))
                    expect(RFCOrdWeekDay.saturday(1).rfcWeekDay).to(equal(RFCWeekDay.saturday))
                    expect(RFCOrdWeekDay.sunday(1).rfcWeekDay).to(equal(RFCWeekDay.sunday))
                }
            }
        }

        describe("BimodalWeekDay") {
            describe("hashing") {
                it("works") {
                    var
                        eachHasher: Hasher = Hasher(),
                        eachNHasher: Hasher = Hasher()

                    eachHasher.combine(BimodalWeekDay.each(.monday))
                    eachNHasher.combine(BimodalWeekDay.eachN(.monday(3)))

                    expect(
                        eachHasher.finalize()
                    ).notTo(equal(eachNHasher.finalize()))
                }
            }
        }

        describe("RFCWhence") {
            describe("initialization") {
                it("defaults to now if no dtstart provided") {
                    let
                        now = Date().date,
                        rfcWhence = RFCWhence()

                    expect(rfcWhence.dtstart).to(beLessThanOrEqualTo(now))
                    expect(rfcWhence.dtstart).to(beCloseTo(now, within: 1))
                }

                it("truncating milliseconds from the provided date") {
                    let
                        dtstart = Date().date, // now
                        rfcWhence = RFCWhence(dtstart)

                    expect(rfcWhence.dtstart).to(beLessThanOrEqualTo(dtstart))
                    expect(rfcWhence.dtstart).to(beCloseTo(dtstart, within: 1))
                }
            }

            describe("validation") {
                it("does not normally throw") {
                    expect {
                        try RFCWhence().validate()
                    }.notTo(throwError())
                }

                it("throws when provided month number is unintelligible") {
                    expect {
                        try RFCWhence().validate(monthNumber: 13)
                    }.to(throwError(RFCWhenceError.invalidMonth(value: 3)))
                }

                it("throws when provided weekday number is unintelligible") {
                    expect {
                        try RFCWhence().validate(weekdayNumber: 8)
                    }.to(throwError(RFCWhenceError.invalidWeekday(value: 8)))
                }
            }
        }

        describe("RFCRuleParameters") {
            describe("defaults") {
                it("sets freq to .yearly") {
                    expect(RFCRRuleParameters().freq).to(equal(.yearly))
                }

                it("sets interval to 1") {
                    expect(RFCRRuleParameters().interval).to(equal(1))
                }

                it("sets wkst to .monday") {
                    expect(RFCRRuleParameters().wkst).to(equal(.monday))
                }

                it("sets interval to nil") {
                    expect(RFCRRuleParameters().count).to(beNil())
                }

                it("sets until to nil") {
                    expect(RFCRRuleParameters().until).to(beNil())
                }
            }

            describe("validation)") {
                it("does not normally throw") {
                    expect {
                        try RFCRRuleParameters().validate()
                    }.notTo(throwError())
                }
            }
        }

        describe("RFCRuleDetails") {
            describe("defaults") {
                it("sets bymonth to .none") {
                    expect(RFCRRuleDetails().bymonth).to(equal(MonthDetail.none))
                }

                it("sets bymonth to .none") {
                    expect(RFCRRuleDetails().bymonthday).to(equal(NumberDetail.none))
                }

                it("sets byweekday to .none") {
                    expect(
                        RFCRRuleDetails().byweekday
                    ).to(equal(BimodalWeekDayDetail.none))
                }

                it("sets bysetpos to .none") {
                    expect(RFCRRuleDetails().bysetpos).to(equal(NumberDetail.none))
                }

                it("sets byyearday to .none") {
                    expect(RFCRRuleDetails().byyearday).to(equal(NumberDetail.none))
                }

                it("sets byweekno to .none") {
                    expect(RFCRRuleDetails().byweekno).to(equal(NumberDetail.none))
                }

                it("sets byhour to .none") {
                    expect(RFCRRuleDetails().byhour).to(equal(NumberDetail.none))
                }

                it("sets byminute to .none") {
                    expect(RFCRRuleDetails().byminute).to(equal(NumberDetail.none))
                }

                it("sets bysecond to .none") {
                    expect(RFCRRuleDetails().bysecond).to(equal(NumberDetail.none))
                }
            }

            describe("isByweeknoAnchored determination") {
                context("when many byweekno is empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .many([])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByweeknoAnchored).to(beFalse())
                    }
                }

                context("when many byweekno is not empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .many([1,3,-366])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isByweeknoAnchored).to(beTrue())
                    }
                }

                context("when one byweekno is non-zero") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isByweeknoAnchored).to(beTrue())
                    }
                }

                context("when none byweekno") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .none
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByweeknoAnchored).to(beFalse())
                    }
                }
            }

            describe("isByyeardayAnchored determination") {
                context("when many byyearday is empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byyearday = .many([])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByyeardayAnchored).to(beFalse())
                    }
                }

                context("when many byyearday is not empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byyearday = .many([1,3,-366])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isByyeardayAnchored).to(beTrue())
                    }
                }

                context("when one byyearday") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byyearday = .one(23)
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByyeardayAnchored).to(beFalse())
                    }
                }

                context("when none byyearday") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byyearday = .none
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByyeardayAnchored).to(beFalse())
                    }
                }
            }

            describe("isBymonthdayAnchored determination") {
                context("when many bymonthday is empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.bymonthday = .many([])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isBymonthdayAnchored).to(beFalse())
                    }
                }

                context("when many bymonthday is not empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.bymonthday = .many([1,3,-366])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isBymonthdayAnchored).to(beTrue())
                    }
                }

                context("when one bymonthday is non-zero") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.bymonthday = .one(23)
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isBymonthdayAnchored).to(beTrue())
                    }
                }

                context("when none bymonthday") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.bymonthday = .none
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isBymonthdayAnchored).to(beFalse())
                    }
                }
            }

            describe("isByweekdayAnchored determination") {
                context("when many byweekday is empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekday = .many([])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByweekdayAnchored).to(beFalse())
                    }
                }

                context("when many byweekday is not empty") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekday = .many([.each(.monday), .eachN(.friday(1))])
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isByweekdayAnchored).to(beTrue())
                    }
                }

                context("when one byweekday") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isByweekdayAnchored).to(beTrue())
                    }
                }

                context("when none byweekday") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekday = .none
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isByweekdayAnchored).to(beFalse())
                    }
                }
            }

            describe("isAnchored determination") {
                context("when all tests are true") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            rfcRRuleDetails.byyearday = .many([42,-10])
                            rfcRRuleDetails.bymonthday = .one(-1)
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns true") {
                        expect(rfcRRuleDetails.isAnchored).to(beTrue())
                    }
                }

                context("when isByweeknoAnchored is false") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            // rfcRRuleDetails.byweekno = .one(23)
                            rfcRRuleDetails.byyearday = .many([42,-10])
                            rfcRRuleDetails.bymonthday = .one(-1)
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isAnchored).to(beFalse())
                    }
                }

                context("when isByyeardayAnchored is false") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            // rfcRRuleDetails.byyearday = .many([42,-10])
                            rfcRRuleDetails.bymonthday = .one(-1)
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isAnchored).to(beFalse())
                    }
                }

                context("when isBymonthdayAnchored is false") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            rfcRRuleDetails.byyearday = .many([42,-10])
                            // rfcRRuleDetails.bymonthday = .one(-1)
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isAnchored).to(beFalse())
                    }
                }

                context("when isBymonthdayAnchored is false") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            rfcRRuleDetails.byyearday = .many([42,-10])
                            rfcRRuleDetails.bymonthday = .one(-1)
                            // rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns false") {
                        expect(rfcRRuleDetails.isAnchored).to(beFalse())
                    }
                }
            }

            describe("anchoring to a date") {
                let reference = "2021-01-01T00:00:00.815479Z".toDate()!.date

                context("when already anchored") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get {
                            var rfcRRuleDetails = RFCRRuleDetails()
                            rfcRRuleDetails.byweekno = .one(23)
                            rfcRRuleDetails.byyearday = .many([42,-10])
                            rfcRRuleDetails.bymonthday = .one(-1)
                            rfcRRuleDetails.byweekday = .one(.each(.monday))
                            return rfcRRuleDetails
                        }
                    }

                    it("returns equal representation") {
                        expect(
                            rfcRRuleDetails.anchored(.yearly, to: reference)
                        ).to(equal(rfcRRuleDetails))
                    }
                }

                context("when not yet anchored") {
                    var rfcRRuleDetails: RFCRRuleDetails {
                        get { RFCRRuleDetails() }
                    }

                    it("returns different representation") {
                        expect(
                            rfcRRuleDetails.anchored(.yearly, to: reference)
                        ).notTo(equal(rfcRRuleDetails))
                    }

                    context("frequency: yearly") {
                        func anchored() -> RFCRRuleDetails {
                            rfcRRuleDetails.anchored(.yearly, to: reference)
                        }

                        it("sets bymonthday to one--that of dtstart's day number") {
                            expect(anchored().bymonthday).to(equal(.one(reference.day)))
                        }

                        it("does not change byweekday") {
                            let _anchored = anchored()

                            expect(_anchored.byweekday).to(equal(rfcRRuleDetails.byweekday))
                        }

                        context("when many bymonth") {
                            var rfcRRuleDetails: RFCRRuleDetails {
                                get {
                                    var rfcRRuleDetails = rfcRRuleDetails
                                    rfcRRuleDetails.bymonth = .many([.april, .january])
                                    return rfcRRuleDetails
                                }
                            }

                            func anchored() -> RFCRRuleDetails {
                                rfcRRuleDetails.anchored(.yearly, to: reference)
                            }

                            it("sets bymonth to many--those of bymonth") {
                                expect(
                                    anchored().bymonth
                                ).to(equal(MonthDetail.many([.april, .january])))
                            }
                        }

                        context("when one bymonth") {
                            var rfcRRuleDetails: RFCRRuleDetails {
                                get {
                                    var rfcRRuleDetails = rfcRRuleDetails
                                    rfcRRuleDetails.bymonth = .one(.october)
                                    return rfcRRuleDetails
                                }
                            }

                            func anchored() -> RFCRRuleDetails {
                                rfcRRuleDetails.anchored(.yearly, to: reference)
                            }

                            it("sets bymonth to one--those of bymonth") {
                                expect(
                                    anchored().bymonth
                                ).to(equal(MonthDetail.one(.october)))
                            }
                        }

                        context("when none bymonth") {
                            var rfcRRuleDetails: RFCRRuleDetails {
                                get {
                                    var rfcRRuleDetails = rfcRRuleDetails
                                    rfcRRuleDetails.bymonth = .none
                                    return rfcRRuleDetails
                                }
                            }

                            func anchored() -> RFCRRuleDetails {
                                rfcRRuleDetails.anchored(.yearly, to: reference)
                            }

                            it("sets bymonth to one--the Month for dtstart's month number") {
                                expect(
                                    anchored().bymonth
                                ).to(equal(.one(Month(rawValue: reference.month - 1)!)))
                            }
                        }
                    }

                    context("frequency: monthly") {
                        var rfcRRuleDetails: RFCRRuleDetails {
                            get { RFCRRuleDetails() }
                        }

                        func anchored() -> RFCRRuleDetails {
                            rfcRRuleDetails.anchored(.monthly, to: reference)
                        }

                        it("sets bymonthday to one--that of dtstart's day number") {
                            expect(
                                anchored().bymonthday
                            ).to(equal(.one(reference.day)))
                        }

                        it("does not change bymonth, bymonthday, or byweekday") {
                            let _anchored = anchored()

                            expect(_anchored.bymonth).to(equal(rfcRRuleDetails.bymonth))
                            expect(_anchored.byweekday).to(equal(rfcRRuleDetails.byweekday))
                        }
                    }

                    context("frequency: weekly") {
                        var rfcRRuleDetails: RFCRRuleDetails {
                            get { RFCRRuleDetails() }
                        }

                        func anchored() -> RFCRRuleDetails {
                            rfcRRuleDetails.anchored(.weekly, to: reference)
                        }

                        it("sets bymonthday to one--the RFCWeekDay for dtstart's weekday number") {
                            expect(
                                anchored().byweekday
                            ).to(equal(
                                .one(.each(WeekDay(rawValue: reference.weekday)!.rfcWeekDay))
                            ))
                        }

                        it("does not change bymonth or bymonthday") {
                            let _anchored = anchored()

                            expect(_anchored.bymonth).to(equal(rfcRRuleDetails.bymonth))
                            expect(_anchored.bymonthday).to(equal(rfcRRuleDetails.bymonthday))
                        }
                    }

                    context("other frequency") {
                        var rfcRRuleDetails: RFCRRuleDetails {
                            get { RFCRRuleDetails() }
                        }

                        func anchored() -> RFCRRuleDetails {
                            rfcRRuleDetails.anchored(.daily, to: reference)
                        }

                        it("does not change bymonth, bymonthday, or byweekday") {
                            let _anchored = anchored()

                            expect(_anchored.bymonth).to(equal(rfcRRuleDetails.bymonth))
                            expect(_anchored.bymonthday).to(equal(rfcRRuleDetails.bymonthday))
                            expect(_anchored.byweekday).to(equal(rfcRRuleDetails.byweekday))
                        }
                    }
                }
            }

            describe("validation") {
                it("does not normally throw") {
                    expect {
                        try RFCRRuleDetails().validate(bysetpos: .many([1,3]))
                    }.notTo(throwError())

                    expect {
                        try RFCRRuleDetails().validate(bysetpos: .one(245))
                    }.notTo(throwError())

                    expect {
                        try RFCRRuleDetails().validate(bysetpos: NumberDetail.none)
                    }.notTo(throwError())
                }

                it("throws when provided setpos is unintelligible") {
                    expect {
                        try RFCRRuleDetails().validate(bysetpos: .many([1,3,-4342]))
                    }.to(throwError(RFCRRuleDetailsError.invalidSetpos(value: -4342)))

                    expect {
                        try RFCRRuleDetails().validate(bysetpos: .one(-4342))
                    }.to(throwError(RFCRRuleDetailsError.invalidSetpos(value: -4342)))
                }

                it("throws when provided weekday number is unintelligible") {
                    expect {
                        try RFCWhence().validate(weekdayNumber: 8)
                    }.to(throwError(RFCWhenceError.invalidWeekday(value: 8)))
                }
            }
        }

        describe("RFCRRule") {
            describe("validation") {
                it("does not normally throw") {
                    let
                        whence = RFCRRuleWhence(),
                        parameters = RFCRRuleParameters(),
                        details = RFCRRuleDetails()

                    expect {
                        try RFCRRule(whence, parameters, details).validate()
                    }.notTo(throwError())
                }
            }
        }

        describe("RFCRRule+CriteriaInterop") {
            describe("representing as criteria") {
                it("does not normally throw") {
                    let
                        whence = RFCRRuleWhence(),
                        parameters = RFCRRuleParameters(),
                        details = RFCRRuleDetails()

                    expect {
                        RFCRRule(whence, parameters, details).criteria
                    }.notTo(throwError())
                }
            }
        }
    }
}
