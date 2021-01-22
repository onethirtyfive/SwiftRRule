//
//  Number+Flattenable.swift
//  SwiftRRule
//
//  Created by Joshua Morris on 1/18/21.
//

import Foundation

extension Number: Flattenable {
    public func flattened() -> Multi<Number> {
        [self]
    }
}
