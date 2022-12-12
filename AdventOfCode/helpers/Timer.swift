//
//  Timer.swift
//  AdventOfCode
//
//  Created by Chris Williamson on 12/12/2022.
//

import Foundation

struct Timer {
    static func time(_ function: () throws -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        try! function()
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Execution time: \(String(format: "%.2f", diff)) seconds")
    }
}
