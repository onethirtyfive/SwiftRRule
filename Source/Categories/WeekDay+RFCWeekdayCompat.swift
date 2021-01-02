//
//  WeekDay+RFCWeekdayCompat.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation
import SwiftDate

protocol RFCWeekdayCompat {
    func toRFCWeekDay() -> RFCWeekDay
}

extension WeekDay: RFCWeekdayCompat {
    public func toRFCWeekDay() -> RFCWeekDay {
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