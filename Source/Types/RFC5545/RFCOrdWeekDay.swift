//
//  RFCOrdWeekDay.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCOrdWeekDay: Hashable {
    case
        monday(_: Ord = 0),
        tuesday(_: Ord = 0),
        wednesday(_: Ord = 0),
        thursday(_: Ord = 0),
        friday(_: Ord = 0),
        saturday(_: Ord = 0),
        sunday(_: Ord = 0)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .monday(let n), .tuesday(let n), .wednesday(let n),
             .thursday(let n), .friday(let n), .saturday(let n),
             .sunday(let n):
            hasher.combine(n)
        }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RFCOrdWeekDay: Equatable {
    public static func == (lhs: RFCOrdWeekDay, rhs: RFCOrdWeekDay) -> Bool {
        switch (lhs, rhs) {
        case
            (.monday(let leftN), .monday(let rightN)),
            (.tuesday(let leftN), .tuesday(let rightN)),
            (.wednesday(let leftN), .wednesday(let rightN)),
            (.thursday(let leftN), .thursday(let rightN)),
            (.friday(let leftN), .friday(let rightN)),
            (.saturday(let leftN), .saturday(let rightN)),
            (.sunday(let leftN), .sunday(let rightN)):
            return leftN == rightN
        default:
            return false
        }
    }
}

extension RFCOrdWeekDay: Comparable {
    public static func zeroCase(_ ordWeekDay: RFCOrdWeekDay) -> Self {
        switch ordWeekDay {
        case .monday(_):
            return .monday(0)
        case .tuesday(_):
            return .tuesday(0)
        case .wednesday(_):
            return .wednesday(0)
        case .thursday(_):
            return .thursday(0)
        case .friday(_):
            return .friday(0)
        case .saturday(_):
            return .saturday(0)
        case .sunday(_):
            return .sunday(0)
        }
    }

    private static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.monday(_), _), (_, .monday(_)):
            return .monday()
        case (.tuesday(_), _), (_, .tuesday(_)):
            return .tuesday()
        case (.wednesday(_), _), (_, .wednesday(_)):
            return .wednesday()
        case (.thursday(_), _), (_, .thursday(_)):
            return .thursday()
        case (.friday(_), _), (_, .friday(_)):
            return .friday()
        case (.saturday(_), _), (_, .saturday(_)):
            return .saturday()
        case (.sunday(_), _), (_, .sunday(_)):
            // technically unreachable, but here for exhaustiveness
            return .sunday()
        }
    }

    public static func < (lhs: RFCOrdWeekDay, rhs: RFCOrdWeekDay) -> Bool {
        // Comparison ignores 'n'
        let
            lhsZero = Self.zeroCase(lhs),
            rhsZero = Self.zeroCase(rhs)

        return lhsZero != rhsZero && lhsZero == Self.minimum(lhsZero, rhsZero)
    }
}

extension RFCOrdWeekDay: RFCWeekDayInterop {
    var rfcWeekDay: RFCWeekDay {
        switch (self) {
        case .monday(_): return .monday
        case .tuesday(_): return .tuesday
        case .wednesday(_): return .wednesday
        case .thursday(_): return .thursday
        case .friday(_): return .friday
        case .saturday(_): return .saturday
        case .sunday(_): return .sunday
        }
    }
}
