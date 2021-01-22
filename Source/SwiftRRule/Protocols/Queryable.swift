//
//  Queryable.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/2/21.
//

import Foundation

public protocol Queryable {
    func all() -> [Date]
    func between(after: Date, before: Date, inclusive: Bool) -> [Date]
    func before(date: Date, inclusive: Bool) -> Date
    func after(date: Date, inclusive: Bool) -> Date
}
