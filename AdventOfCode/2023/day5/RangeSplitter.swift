//
//  SeedRangeProcessor.swift
//  2023.5
//
//  Created by Chris Williamson on 15/12/2023.
//

import Foundation

struct RangeSplitter {
    let firstRange: Range<Int>
    let secondRange: Range<Int>
    let modifier: Int
    
    // modify the first range elements that are included in the second range
    
    func split() -> (modified: Range<Int>?, unmodified: [Range<Int>]) {
        if firstRange.upperBound < secondRange.lowerBound {
            return (nil, [firstRange])
        }
        if firstRange.lowerBound > secondRange.upperBound {
            return (nil, [firstRange])
        }
        
        if firstRange.lowerBound < secondRange.lowerBound
            && firstRange.upperBound >= secondRange.lowerBound
            && firstRange.upperBound < secondRange.upperBound {
            return (
                secondRange.lowerBound+modifier..<firstRange.upperBound+modifier,
                [firstRange.lowerBound..<secondRange.lowerBound]
            )
        }
        
        if secondRange.lowerBound <= firstRange.lowerBound && secondRange.upperBound >= firstRange.upperBound {
            return (firstRange.lowerBound+modifier..<firstRange.upperBound+modifier, [])
        }
        
        if firstRange.lowerBound >= secondRange.lowerBound
            && firstRange.upperBound > secondRange.upperBound {
            return (
                firstRange.lowerBound+modifier..<secondRange.upperBound+modifier,
                [secondRange.upperBound..<firstRange.upperBound]
            )
        }
        
        if firstRange.lowerBound <= secondRange.lowerBound && firstRange.upperBound >= secondRange.upperBound {
            return (
                secondRange.lowerBound + modifier..<secondRange.upperBound + modifier,
                [firstRange.lowerBound..<secondRange.lowerBound, secondRange.upperBound..<firstRange.upperBound]
            )
        }
        assert(false, "Did not split range")
    }
}
