//
//  RFCDetailWeekDay.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/16/21.
//

import Foundation

public enum RFCBimodalWeekDay: Hashable {
    case
        each(_: RFCWeekDay),
        eachN(_: RFCOrdWeekDay)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .each(let weekDay): hasher.combine(weekDay)
        case .eachN(let ordWeekDay): hasher.combine(ordWeekDay)
        }
    }
}

public enum RFCDetailWeekDayError: Error {

}

public enum RFCDetailWeekDay: Validatable, Adequacy, Anchorable, Partitionable {
    public typealias T = RFCBimodalWeekDay

    case
        many(_ members: Multi<RFCBimodalWeekDay>),
        one(_ member: RFCBimodalWeekDay),
        none

    public func validate() throws -> Void {
        // No validation necessary due to use of higher-order enum type.
        // Insane values are impossible.
    }

    public var isAdequate: Bool {
        switch self {
        case .many(let members):
            return !members.isEmpty
        case .one(_):
            return true
        case .none:
            return false
        }
    }

    public func anchored(to anchor: RFCBimodalWeekDay) -> Self {
        return .one(anchor)
    }

    public func partitioned(freq: RFCFrequency) -> Partition {
        var
            multiWeekDay: Multi<Number> = [],
            multiOrdWeekDay: Multi<OrdNumber> = []

        let slot = { (bimodalWeekDay: RFCBimodalWeekDay, ignoreOrd: Bool) -> Void in
            switch bimodalWeekDay {
            case .each(let weekDay):
                multiWeekDay.update(with: weekDay.rawValue)
            case .eachN(let ordWeekDay):
                if ignoreOrd {
                    multiWeekDay.update(with: ordWeekDay.rfcWeekDay.rawValue)
                } else {
                    switch ordWeekDay {
                    case
                        .monday(let ord), .tuesday(let ord),
                        .wednesday(let ord), .thursday(let ord),
                        .friday(let ord), .saturday(let ord), .sunday(let ord):

                        let ordNumber = OrdNumber(
                            ord: ord,
                            number: ordWeekDay.rfcWeekDay.rawValue
                        )
                        multiOrdWeekDay.update(with: ordNumber)
                    }
                }
            }
        }

        let ignoreOrd = freq > .monthly

        switch self {
        case .many(let members):
            for member in members { slot(member, ignoreOrd) }
        case .one(let member):
            slot(member, ignoreOrd)
        case .none:
            break
        }
        return (each: multiWeekDay, eachN: multiOrdWeekDay)
    }
}
