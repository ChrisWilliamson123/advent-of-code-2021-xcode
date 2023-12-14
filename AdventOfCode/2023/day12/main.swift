import Foundation
import Algorithms

enum SpringCondition: String, CustomStringConvertible {
    case operational = "."
    case damaged = "#"
    case unknown = "?"
    
    var description: String { self.rawValue }
}

struct Record {
    let springs: [SpringCondition]
    let damagedSpringGroups: [Int]
    
    var numberOfDamagedSprings: Int {
        damagedSpringGroups.sum()
    }
    
    var numberOfOperationalSprings: Int {
        springs.count - numberOfDamagedSprings
    }
    
    var numberOfUnknownDamagedSprings: Int {
        numberOfDamagedSprings - (springs.counts[.damaged] ?? 0)
    }
    
    var numberOfUnknownOperationalSprings: Int {
        numberOfUnknownConditions - numberOfUnknownDamagedSprings
    }
    
    var numberOfUnknownConditions: Int {
        springs.counts[.unknown] ?? 0
    }
    
    var unknownSpringIndexes: [Int] {
        springs.indexed().filter({ $1 == .unknown }).map({ $0.index })
    }
}

struct KnownRecord {
    let springs: [SpringCondition]
    let damagedSpringGroups: [Int]
    
    var isValid: Bool {
        // Create regex
        let regex = self.regex
        let springsString = springs.map({ $0.rawValue }).joined()
        return !regex.getGreedyMatches(in: springsString).isEmpty
    }
    
    private var regex: Regex {
        var regexString = "\\.*"
        for (index, group) in damagedSpringGroups.enumerated() {
            if index == damagedSpringGroups.count - 1 {
                regexString += "#{\(group)}\\.*"
            } else {
                regexString += "#{\(group)}\\.+"
            }
        }
        return Regex(regexString)
    }
}

/**
 . operational
 # damaged
 ? unknown
 */

// 4721 too low
// 7339 too low
// 7920 too low
func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n")
//    let input = [""]
    
    let records = input.map { line in
        let split = line.split(separator: " ")
        let springs = split[0].compactMap({ SpringCondition(rawValue: String($0)) })
        let damagedSpringGroups = split[1].split(separator: ",").compactMap({ Int($0) })
        return Record(springs: springs, damagedSpringGroups: damagedSpringGroups)
    }
    var total = 0
    var index = 0
    for test in records {
        print("\(index)/\(records.count)")

        let seedString = Array.init(repeating: SpringCondition.damaged, count: test.numberOfUnknownDamagedSprings) + Array.init(repeating: SpringCondition.operational, count: test.numberOfUnknownOperationalSprings)
        let combinations = Set(seedString.uniquePermutations(ofCount: test.numberOfUnknownConditions))
        let zipped = zip(combinations, Array.init(repeating: test.unknownSpringIndexes, count: combinations.count))
        
        var count = 0
        let unknownSpringIndexes = test.unknownSpringIndexes
        for replacement in zipped {
            var newRecord: [SpringCondition] = test.springs
            for i in 0..<replacement.0.count {
                let newChar = replacement.0[i]
                let indexOfNewChar = replacement.1[i]
                newRecord[indexOfNewChar] = newChar
            }
            let knownRecord = KnownRecord(springs: newRecord, damagedSpringGroups: test.damagedSpringGroups)
            
            if knownRecord.isValid {
                count += 1
            }
        }
        total += count
        index += 1
    }
    
    print(total)
}

/*
 (#, 1) return 1
 (., 1) return error
 (?, 1) return 1 as it has to be (#, 1)
 
 (##, 1) return error (grouping != record length)
 (.., 1) return error (no damaged present)
 (??, 1) return 2 (#. or .#)
 (?., 1) return 1 (#.)
 (.?, 1) return 1 (.#)
 */

Timer.time(main)
