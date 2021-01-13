//
//  Mask.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 1/13/21.
//

import Foundation

public enum Mask {
    static let M365 = [
        Array(repeating: 1, count: 31),
        Array(repeating: 2, count: 28),
        Array(repeating: 3, count: 31),
        Array(repeating: 4, count: 30),
        Array(repeating: 5, count: 31),
        Array(repeating: 6, count: 30),
        Array(repeating: 7, count: 31),
        Array(repeating: 8, count: 31),
        Array(repeating: 9, count: 30),
        Array(repeating: 10, count: 31),
        Array(repeating: 11, count: 30),
        Array(repeating: 12, count: 31),
        Array(repeating: 1, count: 7)
    ].joined()

    static let M366 = [
        Array(repeating: 1, count: 31),
        Array(repeating: 2, count: 29),
        Array(repeating: 3, count: 31),
        Array(repeating: 4, count: 30),
        Array(repeating: 5, count: 31),
        Array(repeating: 6, count: 30),
        Array(repeating: 7, count: 31),
        Array(repeating: 8, count: 31),
        Array(repeating: 9, count: 30),
        Array(repeating: 10, count: 31),
        Array(repeating: 11, count: 30),
        Array(repeating: 12, count: 31),
        Array(repeating: 1, count: 7)
    ].joined()

    static let M28 = Array((1...28))
    static let M29 = Array((1...29))
    static let M30 = Array((1...30))
    static let M31 = Array((1...31))

    static let MDAY366 = [
        Array(M31),
        Array(M29),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M31[0...6])
    ].joined()

    static let MDAY365 = [
        Array(M31),
        Array(M28),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M30),
        Array(M31),
        Array(M31[0...6])
    ].joined()

    static let NM28 = Array((-28...(-1)))
    static let NM29 = Array((-29...(-1)))
    static let NM30 = Array((-30...(-1)))
    static let NM31 = Array((-31...(-1)))

    static let NMDAY366 = [
        Array(NM31),
        Array(NM29),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM31[0...6])
    ].joined()

    static let NMDAY365 = [
        Array(NM31),
        Array(NM28),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM30),
        Array(NM31),
        Array(NM31[0...6])
    ].joined()

    static let M366RANGE = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]
    static let M365RANGE = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]

    static let WDAY = Array(repeating: Array((1...7)), count: 55)
}
