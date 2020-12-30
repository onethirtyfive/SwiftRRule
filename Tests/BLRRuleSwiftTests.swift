import XCTest
import Quick
import Nimble

@testable import BLRRuleSwift

class BLRRuleSwiftTestsSpec: QuickSpec {
    override func spec() {
        describe("whatever") {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            expect(BLRRuleSwift().text).to(equal("Hello, World!"))
        }
    }
}

