//
//  Multi.swift
//  BLRRuleSwift
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
