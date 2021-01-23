//
//  RRuleDetail.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/18/21.
//

import Foundation

public typealias ValidityTest<T> = (T) -> Bool
public typealias AdequacyTest<T: Hashable> = (RRuleDetail<T>) -> Bool

public enum RRuleDetailValidationError<T: Hashable>: Error {
    case
        unwarrantedMany(_ members: Multi<T>),
        invalidMember(_ value: T)
}

public enum RRuleDetail<T: Hashable>: Equatable {
    public typealias T = T

    case
        many(_: Multi<T>),
        one(_: T),
        none

    public func validate(using fnIsMemberValid: @escaping ValidityTest<T>) throws -> Void {
        switch self {
        case .many(let members):
            guard members.count > 1 else {
                throw RRuleDetailValidationError.unwarrantedMany(members)
            }

            for member in members {
                guard fnIsMemberValid(member) else {
                    throw RRuleDetailValidationError.invalidMember(member)
                }
            }
        case .one(let member):
            guard fnIsMemberValid(member) else {
                throw RRuleDetailValidationError.invalidMember(member)
            }
        case .none:
            break
        }
    }

    public func anchored(to anchor: T) -> Self {
        type(of: self).one(anchor)
    }
}

// MARK: - Common Implementations

extension Adequacy where Self: ConcreteRRuleDetail {
    public var isAdequate: Bool {
        Self.fnIsAdequate(detail)
    }
}

extension Validatable where Self: ConcreteRRuleDetail {
    public func validate() throws {
        try detail.validate(using: Self.fnIsMemberValid)
    }
}

extension Flattenable where Self: ConcreteRRuleDetail & Flattenable {
    public func flattened() -> Multi<Number> {
        switch detail {
        case .many(let members): return members.flattened()
        case .one(let member): return member.flattened()
        case .none: return []
        }
    }
}

extension Partitionable where Self: ConcreteRRuleDetail & Partitionable {
    public func partitioned(freq: RRuleFreq) -> Multi<Partitioned> {
        switch detail {
        case .many(let members): return members.partitioned(freq: freq)
        case .one(let member): return member.partitioned(freq: freq)
        case .none: return []
        }
    }
}

extension Anchorable where Self: ConcreteRRuleDetail {
    public func anchored(to anchor: T) -> Self {
        type(of: self).init(detail.anchored(to: anchor))
    }
}

// MARK: - Concrete RRule details

internal func manyIsAdequate<T>() -> ( (RRuleDetail<T>) -> Bool ) {
    {
        switch $0 {
        case .many(_):
            return true
        default:
            return false
        }
    }
}

internal func manyOrOneIsAdequate<T>() -> ( (RRuleDetail<T>) -> Bool ) {
    {
        switch $0 {
        case .many(_), .one(_):
            return true
        default:
            return false
        }
    }
}

internal let unconditional = { (_: Any) in true }

public struct Byyearday: ConcreteRRuleDetail, Equatable, Adequacy, Validatable, Flattenable {
    public typealias T = Number
    public static let
        fnIsAdequate: AdequacyTest<T> = manyIsAdequate(),
        fnIsMemberValid: ValidityTest<T> = { (-366...366).contains($0) && $0 != 0 }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Byweekno: ConcreteRRuleDetail, Equatable, Adequacy, Validatable, Flattenable {
    public typealias T = Number
    public static let
        fnIsAdequate: AdequacyTest<T> = manyOrOneIsAdequate(),
        fnIsMemberValid: ValidityTest<T> = { (-53...53).contains($0) && $0 != 0 }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Bysetpos: ConcreteRRuleDetail, Equatable, Validatable, Flattenable {
    public typealias T = Number
    public static let fnIsMemberValid: ValidityTest<T> = { (-366...366).contains($0) && $0 != 0 }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Bymonth: ConcreteRRuleDetail, Equatable, Validatable, Flattenable, Anchorable {
    public typealias T = RRuleMonth
    public static let fnIsMemberValid: ValidityTest<T> = unconditional
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Bymonthday: ConcreteRRuleDetail, Equatable, Adequacy, Validatable, Partitionable, Anchorable {
    public typealias T = Number
    public static let
        fnIsAdequate: AdequacyTest<T> = manyOrOneIsAdequate(),
        fnIsMemberValid = { (-31...31).contains($0) && $0 != 0 }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Byweekday: ConcreteRRuleDetail, Equatable, Adequacy, Validatable, Partitionable, Anchorable {
    public typealias T = RRuleWeekDay
    public static let
        fnIsAdequate: AdequacyTest<T> = manyIsAdequate(),
        fnIsMemberValid: ValidityTest<T> = {
            switch $0 {
            case
                .monday(let n), .tuesday(let n), .wednesday(let n), .thursday(let n), .friday(let n),
                .saturday(let n), .sunday(let n):
                guard n != 0 else {
                    return false
                }
            }
            return true
        }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Byhour: ConcreteRRuleDetail, Equatable, Validatable, Flattenable, Anchorable {
    public typealias T = Number
    public static let fnIsMemberValid: ValidityTest<T> = { (0...23).contains($0) }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Byminute: ConcreteRRuleDetail, Equatable, Validatable, Flattenable, Anchorable {
    public typealias T = Number
    public static let fnIsMemberValid = { (0...59).contains($0) }
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}

public struct Bysecond: ConcreteRRuleDetail, Equatable, Validatable, Flattenable, Anchorable {
    public typealias T = Number
    public static let fnIsMemberValid = { (0...60).contains($0) } // '60' not a typo
    public let detail: RRuleDetail<T>

    public init(_ detail: RRuleDetail<T>) {
        self.detail = detail
    }
}
