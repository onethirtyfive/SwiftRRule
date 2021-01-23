//
//  WeekDay+RRuleWeekdayInterop.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation
import SwiftDate

extension WeekDay: RRuleWeekDayInterop {
    var rruleWeekDay: RRuleWeekDay {
        switch (self) {
        case .monday: return .monday()
        case .tuesday: return .tuesday()
        case .wednesday: return .wednesday()
        case .thursday: return .thursday()
        case .friday: return .friday()
        case .saturday: return .saturday()
        case .sunday: return .sunday()
        }
    }
}
