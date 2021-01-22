//
//  Interop.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

protocol RRuleMonthInterop {
    var rruleMonth: RRuleMonth { get }
}

protocol RRuleWeekDayInterop {
    var rruleWeekDay: RRuleWeekDay { get }
}

protocol MonthInterop {
    var month: Month { get }
}

protocol WeekDayInterop {
    var weekDay: WeekDay { get }
}
