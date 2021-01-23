//
//  Month+RRuleMonthInterop.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

class MonthRRuleMonthInteropSpec: QuickSpec {
    override func spec() {
        it("interoperates with RRuleMonth") {
            expect(Month.january.rruleMonth).to(equal(.january))
            expect(Month.february.rruleMonth).to(equal(.february))
            expect(Month.march.rruleMonth).to(equal(.march))
            expect(Month.april.rruleMonth).to(equal(.april))
            expect(Month.may.rruleMonth).to(equal(.may))
            expect(Month.june.rruleMonth).to(equal(.june))
            expect(Month.july.rruleMonth).to(equal(.july))
            expect(Month.august.rruleMonth).to(equal(.august))
            expect(Month.september.rruleMonth).to(equal(.september))
            expect(Month.october.rruleMonth).to(equal(.october))
            expect(Month.november.rruleMonth).to(equal(.november))
            expect(Month.december.rruleMonth).to(equal(.december))
        }
    }
}
