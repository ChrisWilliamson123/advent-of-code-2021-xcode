//
//  CharGrid+Extensions.swift
//  AdventOfCode
//
//  Created by Chris Williamson on 23/12/2023.
//

import Foundation

extension [[Character]] {
    var coordsToChars: [Coordinate: Character] {
        self.enumerated().reduce(into: [:], { (partial, enumeration) in
            let (yIndex, line) = enumeration
            partial.merge(line.enumerated().reduce(into: [:], { partial, enumeration in
                let (xIndex, character) = enumeration
                let coordinate = Coordinate(xIndex, yIndex)
                partial[coordinate] = character
            }), uniquingKeysWith: { lhs, _ in lhs })
        })
    }
}
