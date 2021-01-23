//
//  WeekDay+RRuleWeekDayInteropSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

class WeekDayRRuleWeekDayInteropSpec: QuickSpec {
    override func spec() {
        it("interoperates with RRuleWeekDay") {
            expect(WeekDay.sunday.rruleWeekDay).to(equal(.sunday()))
            expect(WeekDay.monday.rruleWeekDay).to(equal(.monday()))
            expect(WeekDay.tuesday.rruleWeekDay).to(equal(.tuesday()))
            expect(WeekDay.wednesday.rruleWeekDay).to(equal(.wednesday()))
            expect(WeekDay.thursday.rruleWeekDay).to(equal(.thursday()))
            expect(WeekDay.friday.rruleWeekDay).to(equal(.friday()))
            expect(WeekDay.saturday.rruleWeekDay).to(equal(.saturday()))
        }
    }
}
