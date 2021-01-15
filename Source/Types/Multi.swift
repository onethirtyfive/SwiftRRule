//
//  Multi.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation
import SwiftDate

public typealias Multi<T:Hashable> = Set<T>
public typealias MultiNumber = Multi<Int>
public typealias MultiMonth = Multi<Month>
public typealias MultiWeekDay = Multi<RFCWeekDay>
public typealias MultiOrdWeekDay = Multi<RFCOrdWeekDay>
