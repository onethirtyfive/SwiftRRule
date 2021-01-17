//
//  RFCDetailSecond.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailSecondError: Error {

}

public enum RFCDetailSecond: Validatable, Anchorable, Flattenable {
    public typealias T = Number

    case
        many(_ members: Multi<Number>),
        one(_ member: Number),
        none

    public func validate() throws -> Void {
        // TODO: Validate second values in normative range.
    }

    public func anchored(to anchor: Number) -> Self {
        return .one(anchor)
    }

    public func flattened() -> Multi<Number> {
        switch self {
        case .many(let members):
            return Multi(members)
        case .one(let member):
            return Multi([member])
        case .none:
            return Multi([])
        }
    }
}
