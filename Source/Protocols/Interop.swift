//
//  Interop.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/4/21.
//

import Foundation
import SwiftDate

protocol RFCWeekDayInterop {
    var rfcWeekDay: RFCWeekDay { get }
}

protocol WeekDayInterop {
    var weekDay: WeekDay { get }
}

protocol CriteriaInterop {
    var criteria: Criteria { get }
}
