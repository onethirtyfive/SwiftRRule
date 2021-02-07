//
//  YearInfoSpec.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/29/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}


class YearinfoSpec: QuickSpec {
    override func spec() {
        describe("whatever") {
            it("lol") {
                let
                    epochRounded = "2026-01-01T00:00:00Z".toISODate()!.date,
                    whence = RRuleWhence(epochRounded),
                    parameters = RRuleParameters(dtstart: whence.dtstart)

                var details = RRuleDetails(freq: .weekly, dtstart: whence.dtstart)
                details.byweekno = Byweekno(.many([1, 23, -1]))


                let
                    rrule = RRule(whence, parameters, details),
                    recurrable = try Recurrable(rrule)

                let
                    timespan = YearTimespan(epochRounded.year),
                    yearweeknomask = YearWeeknoMask(timespan, recurrable: recurrable)

                let
                    mask = yearweeknomask.computed,
                    withoutPreceding = Array(mask[yearweeknomask.computedWeekOffset...])

            }
        }
    }
}
