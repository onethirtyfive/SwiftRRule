//
//  Compat.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

protocol RFCWeekDayCompatibility {
    func toRFCWeekDay() -> RFCWeekDay
}

protocol WeekDayCompatibility {
    func toWeekDay() -> WeekDay
}
