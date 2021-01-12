//
//  Multi.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/7/21.
//

import Foundation
import SwiftDate

public typealias Multi<T:Hashable> = Set<T>
public typealias MultiOrd = Multi<Ord>
public typealias MultiMonth = Multi<Month>
public typealias MultiWeekDay = Multi<RFCWeekDay>
public typealias MultiNWeekDay = Multi<RFCNWeekDay>
