//
//  MultiSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import SwiftDate
import Quick
import Nimble

@testable import SwiftRRule

class MultiSpec: QuickSpec {
    override func spec() {
        context("when element is Flattenable") {
            let multi = Multi<Number>([1, 2, -3])

            it("too is flattenable") {
                expect(multi.flattened).to(equal([1, 2, -3]))
            }
        }

        context("when element is Partitionable") {
            // e.g. hasn't yet been partitioned
            let multi = Multi<Number>([1, -3])

            it("too is partitionable") {
                expect(multi.partitioned(freq: .yearly)).to(equal([.value(1), .ordinal(-3, n: 1)]))
            }
        }

        context("when element is Partitioned") {
            // e.g. the result of partitioning
            let multi = Multi<Number>([1, -3, 4])

            it("exopses subset of only values") {
                expect(
                    multi.partitioned(freq: .yearly).values
                ).to(equal([.value(1), .value(4)]))
            }

            it("exopses subset of only ordinals") {
                expect(
                    multi.partitioned(freq: .yearly).ordinals
                ).to(equal([.ordinal(-3, n: 1)]))
            }
        }
    }
}
