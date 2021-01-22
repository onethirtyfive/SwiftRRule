//
//  RFC5545.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum Partitioned: Hashable {
    case
        value(_: Number),
        ordinal(_: Number, n: Number)
}

public protocol Adequacy {
    associatedtype T: Hashable
    static var fnIsAdequate: AdequacyTest<T> { get }
    var isAdequate: Bool { get }
}

public protocol Validatable {
    func validate() throws -> Void
}

public protocol Flattenable {
    associatedtype T: Flattenable
    func flattened() -> Multi<Number>
}

public protocol Partitionable {
    associatedtype T: Partitionable
    func partitioned(freq: RRuleFreq) -> Multi<Partitioned>
}

public protocol Anchorable {
    associatedtype T: Hashable
    func anchored(to anchor: T) -> Self
}

public protocol ConcreteRRuleDetail {
    associatedtype T: Hashable
    static var fnIsMemberValid: ValidityTest<T> { get }
    init(_ detail: RRuleDetail<T>)
    var detail: RRuleDetail<T> { get }
}

// MARK: -

