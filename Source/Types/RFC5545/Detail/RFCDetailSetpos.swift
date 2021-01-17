//
//  RFCDetailSetpos.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCDetailSetposError: Error {
    case outOfBounds(value: Number)
}

public enum RFCDetailSetpos: Validatable, Flattenable {
    public typealias T = Number

    case
        many(_ members: Multi<Number>),
        one(_ member: Number),
        none

    public func validate() throws -> Void {
        let testSetpos =
            { (s: Int) throws -> Void in
                guard (-366...366).contains(s) && s != 0 else {
                    throw RFCDetailSetposError.outOfBounds(value: s)
                }
            }

        switch self {
        case .many(let members):
            for member in members { try testSetpos(member) }
        case .one(let member):
            try testSetpos(member)
        case .none:
            break
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
