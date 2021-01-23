//
//  Number+PartitionableSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class NumberPartitionableSpec: QuickSpec {
    override func spec() {
        it("partitions") {
            expect(1.partitioned(freq: .yearly)).to(equal([.value(1)]))
            expect((-1).partitioned(freq: .yearly)).to(equal([.ordinal(-1, n: 1)]))
        }
    }
}
