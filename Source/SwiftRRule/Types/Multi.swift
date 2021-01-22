//
//  Multi.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation
import SwiftDate

public typealias Number = Int
public typealias Ord = Number
public typealias Multi<T:Hashable> = Set<T>

public struct OrdNumber: Hashable {
    let ord: Ord
    let number: Number
}

extension Multi where Element: Flattenable {
    public func flattened() -> Multi<Number> {
        Multi<Number>(map { $0.flattened() }.joined())
    }
}

extension Multi where Element: Partitionable {
    public func partitioned(freq: RRuleFreq) -> Multi<Partitioned> {
        Multi<Partitioned>(map { $0.partitioned(freq: freq) }.joined())
    }
}

extension Multi where Element == Partitioned {
    public var values: Multi<Partitioned> {
        filter {
            if case .value(_) = $0 {
                return true
            } else {
                return false
            }
        }
    }

    public var ordinals: Multi<Partitioned> {
        filter {
            if case .ordinal(_, _) = $0 {
                return true
            } else {
                return false
            }
        }
    }
}
