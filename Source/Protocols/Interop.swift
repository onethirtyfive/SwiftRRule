//
//  Interop.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

protocol RFCMonthInterop {
    var rfcMonth: RFCMonth { get }
}

protocol RFCWeekDayInterop {
    var rfcWeekDay: RFCWeekDay { get }
}

protocol MonthInterop {
    var month: Month { get }
}

protocol WeekDayInterop {
    var weekDay: WeekDay { get }
}
