//
//  RRuleWeekDay.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation
import SwiftDate

// Zero-indexed and monday-based, unlike SwiftDate's WeekDay. Makes math less painful.

public enum RRuleWeekDay: Hashable, RawRepresentable {
    public typealias RawValue = Number

    case
        monday(n: Ord? = nil),
        tuesday(n: Ord? = nil),
        wednesday(n: Ord? = nil),
        thursday(n: Ord? = nil),
        friday(n: Ord? = nil),
        saturday(n: Ord? = nil),
        sunday(n: Ord? = nil)

    public init?(rawValue: Number) {
        switch rawValue {
        case 0: self = .monday()
        case 1: self = .tuesday()
        case 2: self = .wednesday()
        case 3: self = .thursday()
        case 4: self = .friday()
        case 5: self = .saturday()
        case 6: self = .sunday()
        default:
            return nil
        }
    }

    public func nth(_ n: Number) -> RRuleWeekDay {
        switch self {
        case .monday(_): return .monday(n: n)
        case .tuesday(_): return .tuesday(n: n)
        case .wednesday(_): return .wednesday(n: n)
        case .thursday(_): return .thursday(n: n)
        case .friday(_): return .friday(n: n)
        case .saturday(_): return .saturday(n: n)
        case .sunday(_): return .sunday(n: n)
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case
            .monday(let n),
            .tuesday(let n),
            .wednesday(let n),
            .thursday(let n),
            .friday(let n),
            .saturday(let n),
            .sunday(let n):
            hasher.combine(n)
        }
    }

    public var rawValue: Number {
        switch self {
        case .monday(_): return 0
        case .tuesday(_): return 1
        case .wednesday(_): return 2
        case .thursday(_): return 3
        case .friday(_): return 4
        case .saturday(_): return 5
        case .sunday(_): return 6
        }
    }
}

extension RRuleWeekDay: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case
            (.monday(let lhsN), .monday(let rhsN)),
            (.tuesday(let lhsN), .tuesday(let rhsN)),
            (.wednesday(let lhsN), .wednesday(let rhsN)),
            (.thursday(let lhsN), .thursday(let rhsN)),
            (.friday(let lhsN), .friday(let rhsN)),
            (.saturday(let lhsN), .saturday(let rhsN)),
            (.sunday(let lhsN), .sunday(let rhsN)):
            return lhsN == rhsN
        default:
            return false
        }
    }
}

// Swift 5.3 has synthesized enum Comparable, but this enables earlier version support.
extension RRuleWeekDay: Comparable {
    public static func nilCase(_ weekDay: RRuleWeekDay) -> Self {
        switch weekDay {
        case .monday(_): return .monday()
        case .tuesday(_): return .tuesday()
        case .wednesday(_): return .wednesday()
        case .thursday(_): return .thursday()
        case .friday(_): return .friday()
        case .saturday(_): return .saturday()
        case .sunday(_): return .sunday()
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

    public static func < (lhs: RRuleWeekDay, rhs: RRuleWeekDay) -> Bool {
        // Comparison ignores 'n'
        let
            lhs0 = Self.nilCase(lhs),
            rhs0 = Self.nilCase(rhs)

        return lhs0 != rhs0 && lhs0 == Self.minimum(lhs0, rhs0)
    }
}

extension RRuleWeekDay: WeekDayInterop {
    var weekDay: WeekDay {
        switch self {
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

extension RRuleWeekDay: Partitionable {
    public typealias T = Self

    public func partitioned(freq: RRuleFreq) -> Multi<Partitioned> {
        if freq.isWeeklyOrMore {
            return [.value(self.rawValue)] // ignore n
        } else {
            switch self {
            case
                .monday(let n) where n != nil,
                .tuesday(let n) where n != nil,
                .wednesday(let n) where n != nil,
                .thursday(let n) where n != nil,
                .friday(let n) where n != nil,
                .saturday(let n) where n != nil,
                .sunday(let n) where n != nil:
                return [.ordinal(self.rawValue, n: n!)]
            default:
                return [.value(self.rawValue)]
            }
        }
    }
}
