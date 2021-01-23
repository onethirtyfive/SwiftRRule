//
//  RRuleSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

internal let
    epoch = "2021-01-01T00:00:00.815479Z".toDate()!.date,
    epochRounded = "2021-01-01T00:00:00.0000000Z".toDate()!.date

class RRuleWhenceSpec: QuickSpec {
    override func spec() {
        it("rounds the milliseconds out of the Date") {
            let whence = RRuleWhence(epoch)

            expect(whence.dtstart).to(beLessThanOrEqualTo(epoch))
            expect(whence.dtstart).to(beCloseTo(epochRounded, within: 0.001))
        }

        it("defaults to now") {
            let
                now = Date().date,
                whence = RRuleWhence(now)

            expect(whence.dtstart).to(beLessThanOrEqualTo(now))
            expect(whence.dtstart).to(beCloseTo(now, within: 1))
        }

        it("preserves the time zone") {
            let whence = RRuleWhence(tzid: .americaAruba)
            expect(whence.tzid).to(equal(.americaAruba))
        }

        xit("validates") {
            // pending implementation
        }
    }
}

class RRuleParametersSpec: QuickSpec {
    override func spec() {
        it("initializes") {
            expect {
                RRuleParameters(dtstart: Date().date)
            }.notTo(throwError())
        }

        it("defaults values") {
            let
                now = Date().date,
                parameters = RRuleParameters(dtstart: now)

            expect(parameters.freq).to(equal(.yearly))
            expect(parameters.interval).to(equal(1))
            expect(parameters.wkst).to(equal(.monday()))
            expect(parameters.count).to(beNil())
            expect(parameters.until).to(beNil())
        }

        xit("validates") {
            // pending implementation
        }
    }
}

class RRuleDetailsSpec: QuickSpec {
    override func spec() {

        it("initializes") {
            expect {
                RRuleDetails(freq: .yearly, dtstart: Date().date)
            }.notTo(throwError())
        }

        it("defaults values") {
            let details = RRuleDetails(freq: .yearly, dtstart: Date().date)

            expect(details.byyearday.detail).to(equal(RRuleDetail.none))
            expect(details.byweekno.detail).to(equal(RRuleDetail.none))
            expect(details.bysetpos.detail).to(equal(RRuleDetail.none))
            expect(details.bymonth.detail).to(equal(RRuleDetail.none))
            expect(details.bymonthday.detail).to(equal(RRuleDetail.none))
            expect(details.byweekday.detail).to(equal(RRuleDetail.none))
            expect(details.byhour.detail).to(equal(RRuleDetail.none))
            expect(details.byminute.detail).to(equal(RRuleDetail.none))
            expect(details.bysecond.detail).to(equal(RRuleDetail.none))
        }

        describe("normalizing (aka contextual anchoring") {
            context("when neither byyearday, byweekno, bymonthday, nor byweekday is adequate") {
                context("when freq is .yearly") {
                    let details = RRuleDetails(freq: .yearly, dtstart: epoch)

                    it("anchors bymonthday") {
                        let anchored = Bymonthday(.one(1)) // from epoch
                        expect(details.normal.bymonthday).to(equal(anchored))
                    }

                    context("when bymonth is .none") {
                        var details: RRuleDetails {
                            var details = RRuleDetails(freq: .yearly, dtstart: epoch)
                            details.bymonth = Bymonth(.none)
                            return details
                        }

                        it("anchors bymonth") {
                            let anchored = Bymonth(.one(.january)) // from epoch
                            expect(details.normal.bymonth).to(equal(anchored))
                        }
                    }

                    context("otherwise") {
                        var details: RRuleDetails {
                            var details = RRuleDetails(freq: .yearly, dtstart: epoch)
                            details.bymonth = Bymonth(.one(.february))
                            return details
                        }

                        it("does not anchor bymonth") {
                            expect(details.normal.bymonth).to(equal(details.bymonth)) //restated
                        }
                    }
                }

                // Below, it doesn't matter if the details are adequate.

                context("when freq is .monthly") {
                    let details = RRuleDetails(freq: .monthly, dtstart: epoch)

                    it("anchors bymonthday") {
                        let anchored = Bymonthday(.one(1)) // from epoch
                        expect(details.normal.bymonthday).to(equal(anchored))
                    }
                }

                context("when freq is .weekly") {
                    let details = RRuleDetails(freq: .weekly, dtstart: epoch)

                    it("anchors byweekday") {
                        let anchored = Byweekday(.one(.thursday())) // from epoch
                        expect(details.normal.byweekday).to(equal(anchored))
                    }
                }

                context("otherwise") {
                    let details = RRuleDetails(freq: .daily, dtstart: epoch)

                    it("neither anchors bymonth, bymonthday, nor byweekday") {
                        expect(details.normal.bymonth).to(equal(details.bymonth))
                        expect(details.normal.bymonthday).to(equal(details.bymonthday))
                        expect(details.normal.byweekday).to(equal(details.byweekday))
                    }
                }
            }

            describe("byhour anchoring") {
                context("when less frequent than hourly and byhour is .none") {
                    var details: RRuleDetails {
                        var details = RRuleDetails(freq: .daily, dtstart: epoch)
                        details.byhour = Byhour(.none)
                        return details
                    }

                    it("anchors byhour") {
                        let anchored = Byhour(.one(0)) // from epoch
                        expect(details.normal.byhour).to(equal(anchored))
                    }
                }

                context("otherwise") {
                    let details = RRuleDetails(freq: .hourly, dtstart: epoch)

                    it("does not anchor byhour") {
                        expect(details.normal.byhour).to(equal(details.byhour))
                    }
                }
            }

            describe("byminute anchoring") {
                context("when less frequent than minutely and byminute is .none") {
                    var details: RRuleDetails {
                        var details = RRuleDetails(freq: .hourly, dtstart: epoch)
                        details.byminute = Byminute(.none)
                        return details
                    }

                    it("anchors byminute") {
                        let anchored = Byminute(.one(0)) // from epoch
                        expect(details.normal.byminute).to(equal(anchored))
                    }
                }

                context("otherwise") {
                    let details = RRuleDetails(freq: .minutely, dtstart: epoch)

                    it("does not anchor byminute") {
                        expect(details.normal.byminute).to(equal(details.byminute))
                    }
                }
            }

            describe("bysecond anchoring") {
                context("when less frequent than secondly and bysecond is .none") {
                    var details: RRuleDetails {
                        var details = RRuleDetails(freq: .minutely, dtstart: epoch)
                        details.bysecond = Bysecond(.none)
                        return details
                    }

                    it("anchors bysecond") {
                        let anchored = Bysecond(.one(0)) // from epoch
                        expect(details.normal.bysecond).to(equal(anchored))
                    }
                }

                context("otherwise") {
                    let details = RRuleDetails(freq: .secondly, dtstart: epoch)

                    it("does not anchor bysecond") {
                        expect(details.normal.bysecond).to(equal(details.bysecond))
                    }
                }
            }
        }
    }
}

class RRuleSpec: QuickSpec {
    override func spec() {
        var rrule: RRule {
            let
                whence = RRuleWhence(epoch),
                parameters = RRuleParameters(dtstart: whence.dtstart),
                details = RRuleDetails(freq: parameters.freq, dtstart: whence.dtstart)

            return RRule(whence, parameters, details)
        }

        it("is inadequate with defaults") {
            expect(rrule.isAdequate).to(beFalse())
        }
    }
}

class NormalRRuleSpec: QuickSpec {
    override func spec() {
        xit("transforms rrule into normalized form") {
            // pending implementation
        }
    }
}

class NormalValidRRuleSpec: QuickSpec {
    override func spec() {
        xit("validates normalized form") {
            // pending implementation
        }
    }
}
