//
//  RFCDetailMonth.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailMonthError: Error {

}

public enum RFCDetailMonth: Validatable, Anchorable, Flattenable {
    public typealias T = RFCMonth

    case
        many(_ members: Multi<RFCMonth>),
        one(_ member: RFCMonth),
        none

    public func validate() throws -> Void {
        // No validation necessary due to use of higher-order enum type.
        // Insane values are impossible.
    }

    public func anchored(to anchor: RFCMonth) -> Self {
        return .one(anchor)
    }

    public func flattened() -> Multi<Number> {
        // Call sites determine necessity of anchor. If present, it's always used.
        switch self {
        case .many(let members):
            return Multi<Number>(members.map { $0.rawValue })
        case .one(let member):
            return Multi<Number>([member.rawValue])
        case .none:
            return Multi<Number>([])
        }
    }
}
