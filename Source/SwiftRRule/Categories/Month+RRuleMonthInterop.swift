//
//  Month+RRuleMonthInterop.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/15/21.
//

import Foundation
import SwiftDate

extension Month: RRuleMonthInterop {
    var rruleMonth: RRuleMonth {
        switch (self) {
        case .january: return .january
        case .february: return .february
        case .march: return .march
        case .april: return .april
        case .may: return .may
        case .june: return .june
        case .july: return .july
        case .august: return .august
        case .september: return .september
        case .october: return .october
        case .november: return .november
        case .december: return .december
        }
    }
}
