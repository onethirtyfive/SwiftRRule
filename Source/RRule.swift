//
//  RRule.swift
//  BLRRuleSwiftTests
//
//  Created by Joshua Morris on 12/30/20.
//

import Foundation

public class RRule {
    // let _cache: Cache?
    let options: Options
    let configuration: Configuration

    init(options: Options, noCache: Bool = false) throws {
        // self._cache = noCache ? nil : Cache()
        self.options = options
        self.configuration = try Configuring.configure(options)
    }
}
