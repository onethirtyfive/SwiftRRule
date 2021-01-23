//
//  Number+FlattenableSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/22/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class NumberFlattenableSpec: QuickSpec {
    override func spec() {
        it("flattens") {
            expect(1.flattened()).to(equal([1]))
        }
    }
}
