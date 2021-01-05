//
//  Compat.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

protocol RFCWeekDayCompat {
    func toRFCWeekDay() -> RFCWeekDay
}

protocol WeekDayCompat {
    func toWeekDay() -> WeekDay
}
