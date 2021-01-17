//
//  RFCDetailYearday.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailYeardayError: Error {

}

public enum RFCDetailYearday: Validatable, Adequacy, Flattenable {
    public typealias T = Number

    case
        many(_ members: Multi<Number>),
        one(_ member: Number),
        none

    public func validate() throws -> Void {
        // TODO: Validate yearday values in normative range.
    }

    public var isAdequate: Bool {
        switch self {
        case .many(let members):
            return !members.isEmpty
        default:
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
