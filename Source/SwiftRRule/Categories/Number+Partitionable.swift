//
//  Number+Partitionable.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/18/21.
//

import Foundation

extension Number: Partitionable {
    public typealias T = Self

    public func partitioned(freq: RRuleFreq) -> Multi<Partitioned> {
        if self < 0 {
            return [.ordinal(self, n: 1)]
        } else {
            return [.value(self)]
        }
    }
}
