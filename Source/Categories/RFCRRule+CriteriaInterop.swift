//
//  RFCRRule+CriteriaInterop.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/10/21.
//

import Foundation
import SwiftDate

extension RFCRRule: CriteriaInterop {
    var criteria: Criteria {
        get {
            let
                setposCriterion = Criterion<Ord>(details.bysetpos),
                yeardayCriterion = Criterion<Ord>(details.byyearday),
                weeknoCriterion = Criterion<Ord>(details.byweekno),
                monthCriterion = Criterion<Month>(details.bymonth),
                hourCriterion = AnchoredCriterion<Ord>(
                    details.byhour,
                    anchor: whence.dtstart.hour
                ),
                minuteCriterion = AnchoredCriterion<Ord>(
                    details.byhour,
                    anchor: whence.dtstart.minute
                ),
                secondCriterion = AnchoredCriterion<Ord>(
                    details.byhour,
                    anchor: whence.dtstart.second
                ),
                monthdayCriterion =
                    MonthdayCriterion<Ord,Ord,Ord>(details.bymonthday),
                weekDayCriterion =
                    WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCNWeekDay>(
                        details.byweekday,
                        ignoreN: (parameters.freq > .monthly)
                    )

            return Criteria(
                whichSetpos: setposCriterion,
                whichYearday: yeardayCriterion,
                whichWeekno: weeknoCriterion,
                whichMonth: monthCriterion,
                whichHour: hourCriterion,
                whichMinute: minuteCriterion,
                whichSecond: secondCriterion,
                whichMonthday: monthdayCriterion,
                whichWeekDay: weekDayCriterion
            )
        }
    }
}
