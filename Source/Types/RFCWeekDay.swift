//
//  RFCWeekDay.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation
import SwiftDate

public enum RFCWeekDay {
    case
        monday(n: Int? = nil),
        tuesday(n: Int? = nil),
        wednesday(n: Int? = nil),
        thursday(n: Int? = nil),
        friday(n: Int? = nil),
        saturday(n: Int? = nil),
        sunday(n: Int? = nil)

    public func toString() -> String {
        switch self {
        case .monday: return "MO"
        case .tuesday: return "TU"
        case .wednesday: return "WE"
        case .thursday: return "TH"
        case .friday: return "FR"
        case .saturday: return "SA"
        case .sunday: return "SU"
        }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCWeekDay: Comparable {
    public static func < (lhs: RFCWeekDay, rhs: RFCWeekDay) -> Bool {
        return (lhs != rhs) && (lhs == Self.minimum(lhs, rhs))
    }

    private static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.monday(n: _), _), (_, .monday(n: _)):
            return .monday()
        case (.tuesday(n: _), _), (_, .tuesday(n: _)):
            return .tuesday()
        case (.wednesday(n: _), _), (_, .wednesday(n: _)):
            return .wednesday()
        case (.thursday(n: _), _), (_, .thursday(n: _)):
            return .thursday()
        case (.friday(n: _), _), (_, .friday(n: _)):
            return .friday()
        case (.saturday(n: _), _), (_, .saturday(n: _)):
            return .saturday()
        case (.sunday(n: _), _), (_, .sunday(n: _)):
            return .sunday()
        }
    }
}
