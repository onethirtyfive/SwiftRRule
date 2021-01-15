//
//  Criteria.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/11/21.
//

import Foundation
import SwiftDate

public protocol Flattenable {
    associatedtype T: Hashable

    var detail: Cardinality<T> { get }
    var flattened: Multi<T> { get }
}

public protocol Partitionable {
    associatedtype T: Hashable & Equatable
    associatedtype U: Hashable
    associatedtype V: Hashable

    var detail: Cardinality<T> { get }
    var partitioned: (each: Multi<U>, eachN: Multi<V>) { get }
}

// MARK: -

public struct Criterion<T: Hashable>: Flattenable {
    public var detail: Cardinality<T>

    public var flattened: Multi<T> {
        get {
            switch detail {
            case .many(let many):
                return many
            case .one(let one):
                return [one]
            case .none:
                return []
            }
        }
    }

    init(_ detail: Cardinality<T>) {
        self.detail = detail
    }
}

public struct AnchoredCriterion<T: Hashable>: Flattenable {
    public var detail: Cardinality<T>
    let anchor: T

    public var flattened: Multi<T> {
        get {
            switch detail {
            case .many(let many):
                return many
            case .one(let one):
                return [one]
            case .none:
                return [anchor]
            }
        }
    }

    init(_ detail: Cardinality<T>, anchor: T) {
        self.detail = detail
        self.anchor = anchor
    }
}

public struct MonthdayCriterion<T: Hashable,U: Hashable & BinaryInteger, V: Hashable>: Partitionable {
    public var detail: Cardinality<T>

    public var partitioned: (each: Multi<U>, eachN: Multi<V>) {
        get {
            var
                manyMonthday: Multi<U> = [],
                manyNmonthday: Multi<V> = []

            let contextualUpdate = { (monthday: U) -> Void in
                if monthday > 0 { manyMonthday.update(with: monthday) }
                if monthday < 0 { manyNmonthday.update(with: monthday as! V) }
            }

            switch detail {
            case .many(let many):
                for one in many { contextualUpdate(one as! U) }
            case .one(let one):
                contextualUpdate(one as! U)
            default:
                break
            }

            return (each: manyMonthday, eachN: manyNmonthday)
        }
    }

    init(_ detail: Cardinality<T>) {
        self.detail = detail
    }
}

public struct WeekDayCriterion<T: Hashable & Equatable,U: Hashable, V:Hashable>: Partitionable {
    public var detail: Cardinality<T>
    let ignoreN: Bool

    public var partitioned: (each: Multi<U>, eachN: Multi<V>) {
        get {
            var
                manyWeekDay: Multi<U> = [],
                manyOrdWeekDay: Multi<V> = []

            let contextualUpdate = { (bimodalWeekDay: BimodalWeekDay) -> Void in
                switch bimodalWeekDay {
                case .each(let weekDay):
                    manyWeekDay.update(with: weekDay as! U)
                case .eachN(let ordWeekDay):
                    if ignoreN {
                        manyWeekDay.update(with: ordWeekDay.rfcWeekDay as! U)
                    } else {
                        manyOrdWeekDay.update(with: ordWeekDay as! V)
                    }
                }
            }

            switch detail {
            case .many(let many):
                for one in many { contextualUpdate(one as! BimodalWeekDay) }
            case .one(let one):
                contextualUpdate(one as! BimodalWeekDay)
            case .none:
                break
            }

            return (each: manyWeekDay, eachN: manyOrdWeekDay)
        }
    }

    init(_ detail: Cardinality<T>, ignoreN: Bool) {
        self.detail = detail
        self.ignoreN = ignoreN
    }
}

// MARK: -

public typealias Whence = RFCRRuleWhence
public typealias Parameters = RFCRRuleParameters

public struct Criteria {
    let
        whichSetpos: Criterion<Number>,
        whichYearday: Criterion<Number>,
        whichWeekno: Criterion<Number>,
        whichMonth: Criterion<Month>,
        whichHour: AnchoredCriterion<Number>,
        whichMinute: AnchoredCriterion<Number>,
        whichSecond: AnchoredCriterion<Number>,
        whichMonthday: MonthdayCriterion<Number,Number,Number>,
        whichWeekDay: WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>

    // MARK: -

    var normalMonthday: MultiNumber {
        get {
            let (normalWeekDay, _) = whichMonthday.partitioned
            return normalWeekDay
        }
    }

    var normalOrdMonthday: MultiNumber {
        get {
            let (_, normalOrdWeekDay) = whichMonthday.partitioned
            return normalOrdWeekDay
        }
    }

    var normalSetpos: MultiNumber {
        get { whichSetpos.flattened }
    }

    var normalYearday: MultiNumber {
        get { whichYearday.flattened }
    }

    var normalWeekno: MultiNumber {
        get { whichWeekno.flattened }
    }

    var normalMonth: Multi<Month> {
        get { whichMonth.flattened }
    }

    var normalWeekDay: MultiWeekDay {
        get {
            let (normalWeekDay, _) = whichWeekDay.partitioned
            return normalWeekDay
        }
    }

    var normalOrdWeekDay: MultiOrdWeekDay {
        get {
            let (_, normalOrdWeekDay) = whichWeekDay.partitioned
            return normalOrdWeekDay
        }
    }

    var normalHour: MultiNumber {
        get { whichHour.flattened }
    }

    var normalMinute: MultiNumber {
        get { whichMinute.flattened }
    }

    var normalSecond: MultiNumber {
        get { whichSecond.flattened }
    }
}
