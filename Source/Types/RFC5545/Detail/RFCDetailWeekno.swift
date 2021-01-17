//
//  RFCDetailWeekno.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailWeeknoError: Error {

}

public enum RFCDetailWeekno: Validatable, Adequacy, Flattenable {
    public typealias T = Number

    case
        many(_ members: Multi<Number>),
        one(_ member: Number),
        none

    public func validate() throws -> Void {
        // TODO: Validate weekno values in normative range.
    }

    public var isAdequate: Bool {
        switch self {
        case .many(let many):
            return !many.isEmpty
        case .one(_):
            return true
        case .none:
            return false
        }
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
