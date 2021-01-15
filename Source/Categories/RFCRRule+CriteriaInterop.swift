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
                setposCriterion = Criterion<Number>(details.bysetpos),
                yeardayCriterion = Criterion<Number>(details.byyearday),
                weeknoCriterion = Criterion<Number>(details.byweekno),
                monthCriterion = Criterion<Month>(details.bymonth),
                hourCriterion = AnchoredCriterion<Number>(
                    details.byhour,
                    anchor: whence.dtstart.hour
                ),
                minuteCriterion = AnchoredCriterion<Number>(
                    details.byhour,
                    anchor: whence.dtstart.minute
                ),
                secondCriterion = AnchoredCriterion<Number>(
                    details.byhour,
                    anchor: whence.dtstart.second
                ),
                monthdayCriterion =
                    MonthdayCriterion<Number,Number,Number>(details.bymonthday),
                weekDayCriterion =
                    WeekDayCriterion<BimodalWeekDay,RFCWeekDay,RFCOrdWeekDay>(
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
