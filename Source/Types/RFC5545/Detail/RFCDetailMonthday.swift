//
//  RFCBymonthday.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailMonthdayError: Error {

}

public enum RFCDetailMonthday: Validatable, Adequacy, Anchorable, Partitionable {
    public typealias T = Number

    case
        many(_ members: Multi<Number>),
        one(_ member: Number),
        none

    public func validate() throws -> Void {
        // TODO: Validate monthday values in normative range.
    }

    public var isAdequate: Bool {
        switch self {
        case .many(let members):
            return !members.isEmpty
        case .one(let member):
            return member != 0
        case .none:
            return false
        }
    }

    public func anchored(to anchor: Number) -> Self {
        return .one(anchor)
    }

    public func partitioned(freq: RFCFrequency) -> Partition {
        var
            multiMonthday: Multi<Number> = [],
            multiOrdMonthday: Multi<OrdNumber> = []

        let slot = { (monthday: Number) in
            switch monthday {
            case (..<0):
                let ordNumber = OrdNumber(ord: 0, number: monthday)
                multiOrdMonthday.update(with: ordNumber)
            case (1...):
                multiMonthday.update(with: monthday)
            default:
                break
            }
        }

        switch self {
        case .many(let members):
            for member in members { slot(member) }
        case .one(let member):
            slot(member)
        case .none:
            break
        }

        return (each: multiMonthday, eachN: multiOrdMonthday)
    }
}
