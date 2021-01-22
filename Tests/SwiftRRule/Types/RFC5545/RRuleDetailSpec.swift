//
//  RRuleDetailSpec.swift
//  SwiftRRuleTests
//
//  Created by Joshua Morris on 1/17/21.
//

import Foundation
import Quick
import Nimble

@testable import SwiftRRule

class RRuleDetailSpec: QuickSpec {
    override func spec() {
        describe(".many") {
            describe("validation") {
                let
                    unconditionallyValid: ValidityTest<Number> = unconditional,
                    unconditionallyInvalid: ((Any) -> Bool) = { _ in false }

                context(".many") {
                    context("all valid members") {
                        let detail = RRuleDetail<Number>.many([1, -42])

                        it("does not throw") {
                            expect {
                                try detail.validate(using: unconditionallyValid)
                            }.notTo(throwError())
                        }
                    }

                    context("unwarranted many") {
                        let detail1 = RRuleDetail<Number>.many([])
                        let detail2 = RRuleDetail<Number>.many([1])

                        it("throws a specific error") {
                            let error = RRuleDetailValidationError.unwarrantedMany([] as Multi<Number>)
                            expect {
                                try detail1.validate(using: unconditionallyValid)
                            }.to(throwError(error))
                        }

                        it("throws a specific error") {
                            let error = RRuleDetailValidationError.unwarrantedMany([1])
                            expect {
                                try detail2.validate(using: unconditionallyValid)
                            }.to(throwError(error))
                        }
                    }

                    context("invalid member") {
                        let detail = RRuleDetail<Number>.many([1, -42])

                        it("throws a specific error") {
                            let error = RRuleDetailValidationError.invalidMember(-42)
                            expect {
                                try detail.validate(using: unconditionallyInvalid)
                            }.to(throwError(error))
                        }
                    }
                }

                context(".one") {
                    context("valid member") {
                        let detail = RRuleDetail<Number>.one(1)

                        it("does not throw") {
                            expect {
                                try detail.validate { $0 != 13 }
                            }.notTo(throwError())
                        }
                    }

                    context("invalid member") {
                        let detail = RRuleDetail<Number>.one(13)

                        it("throws a specific error") {
                            let error = RRuleDetailValidationError.invalidMember(-42)
                            expect {
                                try detail.validate(using: unconditionallyInvalid)
                            }.to(throwError(error))
                        }
                    }
                }

                context(".none") {
                    context("succeeds") {
                        let detail = RRuleDetail<Number>.none

                        it("does not throw") {
                            expect {
                                try detail.validate(using: unconditionallyValid)
                            }.notTo(throwError())
                        }
                    }
                }
            }
        }
    }
}

class AdequacyConcreteDetailSpec: QuickSpec {
    private struct MockAdequacyDetailMany: ConcreteRRuleDetail, Adequacy {
        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = manyIsAdequate(),
            fnIsMemberValid: ValidityTest<T> = unconditional // required by ConcreteRRuleDetail, not used here
        let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    private struct MockAdequacyDetailManyOrOne: ConcreteRRuleDetail, Adequacy {
        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = manyOrOneIsAdequate(),
            fnIsMemberValid: ValidityTest<T> = unconditional // required by ConcreteRRuleDetail, not used here
        let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    override func spec() {
        describe("many") {
            it("uses the provided function") {
                let
                    detail1 = MockAdequacyDetailMany(.many([1,2,3])),
                    detail2 = MockAdequacyDetailMany(.one(1)),
                    detail3 = MockAdequacyDetailMany(.none)

                expect(detail1.isAdequate).to(beTrue())
                expect(detail2.isAdequate).to(beFalse())
                expect(detail3.isAdequate).to(beFalse())
            }
        }

        describe("many or one") {
            it("uses the provided function") {
                let
                    detail1 = MockAdequacyDetailManyOrOne(.many([1,2,3])),
                    detail2 = MockAdequacyDetailManyOrOne(.one(1)),
                    detail3 = MockAdequacyDetailManyOrOne(.none)

                expect(detail1.isAdequate).to(beTrue())
                expect(detail2.isAdequate).to(beTrue())
                expect(detail3.isAdequate).to(beFalse())
            }
        }
    }
}

class ValidatableConcreteDetailSpec: QuickSpec {
    private struct MockValidatableDetail: ConcreteRRuleDetail, Validatable {
        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = unconditional, // required by ConcreteRRuleDetail, not used here
            fnIsMemberValid: ValidityTest<T> = { $0 != 42 }
        public let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    override func spec() {
        describe("validation") {
            it("uses the provided function") {
                let
                    detail1 = MockValidatableDetail(.many([1,2,3,42])),
                    detail2 = MockValidatableDetail(.one(42)),
                    detail3 = MockValidatableDetail(.one(43)),
                    detail4 = MockValidatableDetail(.one(43))

                expect {
                    try detail1.validate()
                }.to(throwError(RRuleDetailValidationError.invalidMember(42)))

                expect {
                    try detail2.validate()
                }.to(throwError(RRuleDetailValidationError.invalidMember(42)))

                expect {
                    try detail3.validate()
                }.notTo(throwError())

                expect {
                    try detail4.validate()
                }.notTo(throwError())
            }
        }
    }
}

class FlattenableConcreteDetailSpec: QuickSpec {
    private struct MockFlattenableDetail: ConcreteRRuleDetail, Flattenable {
        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = unconditional, // required by ConcreteRRuleDetail, not used here
            fnIsMemberValid: ValidityTest<T> = unconditional // required by ConcreteRRuleDetail, not used here
        let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    override func spec() {
        describe("flattening") {
            let
                detail1 = MockFlattenableDetail(.many([1,1,1,2,3,4,5,5])),
                detail2 = MockFlattenableDetail(.many([1,2,3])),
                detail3 = MockFlattenableDetail(.one(-13)),
                detail4 = MockFlattenableDetail(.none)

            it("uniques") {
                expect(detail1.flattened()).to(equal([1,2,3,4,5]))
            }

            it("works for all cardinalities") {
                expect(detail2.flattened()).to(equal([1,2,3]))
                expect(detail3.flattened()).to(equal([-13]))
                expect(detail4.flattened()).to(equal([]))
            }
        }
    }
}

class PartitionableConcreteDetailSpec: QuickSpec {
    private struct MockPartitionableDetail: ConcreteRRuleDetail, Partitionable {
        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = unconditional, // required by ConcreteRRuleDetail, not used here
            fnIsMemberValid: ValidityTest<T> = unconditional // required by ConcreteRRuleDetail, not used here
        let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    override func spec() {
        describe("partitioning") {
            let
                detail1 = MockPartitionableDetail(.many([1,1,1,-3])),
                detail2 = MockPartitionableDetail(.many([1,3])),
                detail3 = MockPartitionableDetail(.one(-13)),
                detail4 = MockPartitionableDetail(.none)

            it("uniques") {
                // The output here is a behavior tied to the number type. Negatives are ordinals.
                expect(detail1.partitioned(freq: .yearly)).to(equal([.value(1), .ordinal(-3, n: 1)]))
            }

            it("works for all cardinalities") {
                // The output here is a behavior tied to the number type. Negatives are ordinals.
                expect(detail2.partitioned(freq: .yearly)).to(equal([.value(1), .value(3)]))
                expect(detail3.partitioned(freq: .yearly)).to(equal([.ordinal(-13, n: 1)]))
                expect(detail4.partitioned(freq: .yearly)).to(equal([]))
            }
        }
    }
}

class AnchorableConcreteDetailSpec: QuickSpec {
    private struct MockAnchorableDetail: ConcreteRRuleDetail, Anchorable, Equatable {
        static func == (lhs: MockAnchorableDetail, rhs: MockAnchorableDetail) -> Bool {
            // Shortcut, good enough.
            lhs.detail == rhs.detail
        }

        public typealias T = Number
        public static let
            fnIsAdequate: AdequacyTest<T> = unconditional, // required by ConcreteRRuleDetail, not used here
            fnIsMemberValid: ValidityTest<T> = unconditional // required by ConcreteRRuleDetail, not used here
        let detail: RRuleDetail<T>

        public init(_ detail: RRuleDetail<T>) {
            self.detail = detail
        }
    }

    override func spec() {
        describe("partitioning") {
            let
                detail1 = MockAnchorableDetail(.many([1,3])),
                detail2 = MockAnchorableDetail(.one(-13)),
                detail3 = MockAnchorableDetail(.none)

            it("anchors for all cardinalities") {
                // The output here is a behavior tied to the number type. Negatives are ordinals.
                expect(detail1.anchored(to: 42)).to(equal(MockAnchorableDetail(.one(42))))
                expect(detail2.anchored(to: 42)).to(equal(MockAnchorableDetail(.one(42))))
                expect(detail3.anchored(to: 42)).to(equal(MockAnchorableDetail(.one(42))))
            }
        }

        describe("actual types: jogging validation for coverage") {
            it("jogs the code") {
                expect {
                    try Byyearday(.one(1)).validate()
                    try Byweekno(.one(52)).validate()
                    try Bysetpos(.one(-366)).validate()
                    try Bymonth(.one(.january)).validate()
                    try Bymonthday(.one(31)).validate()
                    try Byweekday(.one(.friday())).validate()
                    try Byhour(.one(12)).validate()
                    try Byminute(.one(59)).validate()
                    try Bysecond(.one(60)).validate()
                }.notTo(throwError())
            }
        }
    }
}
