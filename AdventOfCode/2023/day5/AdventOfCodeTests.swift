//
//  AdventOfCodeTests.swift
//  AdventOfCodeTests
//
//  Created by Chris Williamson on 15/12/2023.
//

import XCTest

final class AdventOfCodeTests: XCTestCase {
    
    private let modifier = 5

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_firstRangeFullyLowerThanSecondRange() {
        let first = 1..<10
        let second = 20..<30
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        
        XCTAssertEqual(result, [first])
    }
    
    func test_firstRangeFullyHigherThanSecondRange() {
        let first = 40..<50
        let second = 20..<30
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        
        XCTAssertEqual(result, [first])
    }
    
    func test_firstRangeCoversLowerBoundOfSecondRange() {
        let first = 15..<25
        let second = 20..<30
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        let expected = [15..<20, 25..<30]
        
        XCTAssertEqual(result, expected)
    }
    
    func test_SecondRangeFullyCoversFirstRange() {
        let first = 15..<25
        let second = 10..<30
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        let expected = [20..<30]
        
        XCTAssertEqual(result, expected)
    }
    
    func test_firstRangeCoversUpperBoundOfSecondRange() {
        let first = 25..<35
        let second = 20..<30
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        let expected = [30..<35, 30..<35]
        
        XCTAssertEqual(result, expected)
    }
    
    func test_firstFullCoversSecondRange() {
        let first = 20..<40
        let second = 25..<35
        
        let result = RangeSplitter(firstRange: first, secondRange: second, modifier: modifier).split()
        let expected = [20..<25, 30..<40, 35..<40]
        
        XCTAssertEqual(result, expected)
    }
}
