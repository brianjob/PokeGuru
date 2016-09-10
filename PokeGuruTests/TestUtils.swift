//
//  TestUtils.swift
//  PokeGuru
//
//  Created by Brian Barton on 9/9/16.
//  Copyright © 2016 Brian Barton. All rights reserved.
//

import Foundation

class TestUtils {
    static func equal(a: Double, _ b: Double) -> Bool {
        return abs(a - b) <= 0.001
    }
}