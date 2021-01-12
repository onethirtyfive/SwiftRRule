//
//  Recurrable.swift
//  BLRRuleSwift
//
//  Created by Joshua Morris on 1/10/21.
//

import Foundation

public struct Recurrable {
    let
        whence: Whence,
        parameters: Parameters,
        criteria: Criteria

    init(_ whence: Whence, _ parameters: Parameters, _ criteria: Criteria) {
        self.whence = whence
        self.parameters = parameters
        self.criteria = criteria
    }
}
