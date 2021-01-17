//
//  RFC5545.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

// MARK: - RFCRRule, RFCRRuleDetails, and perinent RFCRRuleDetail members

public protocol Adequacy {
    var isAdequate: Bool { get }
}

// MARK: - RFCRRule, RFCWhence, RFCParameters, RFCRRuleDetails, and RFCRRuleDetail members

public protocol Validatable {
    // TODO: Better error semantics.
    func validate() throws -> Void
}

// MARK: - RFCRRule, RFCRRuleDetails

public protocol Normalizable {
    associatedtype T
    func normalize() throws -> T
}

// MARK: - RFCRRuleDetails members

public typealias Partition = (each: Multi<Number>, eachN: Multi<OrdNumber>)

public protocol Anchorable {
    associatedtype T: Hashable
    func anchored(to: T) -> Self
}

public protocol Flattenable {
    associatedtype T: Hashable
    func flattened() -> Multi<Number>
}

public protocol Partitionable {
    associatedtype T: Hashable
    func partitioned(freq: RFCFrequency) -> Partition
}

