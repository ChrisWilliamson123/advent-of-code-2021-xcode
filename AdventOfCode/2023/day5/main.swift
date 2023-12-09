import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let seeds = Regex("\\d+").getGreedyMatches(in: input[0]).compactMap({ Int($0) })
    print(seeds)
    
    let maps = input[1..<input.count].map({ mappingString in
        // Want to return an array of maps
        let lineSplit = mappingString.components(separatedBy: "\n").filter({ !$0.isEmpty })
        var mappings: [[Range<Int>: Range<Int>]] = []
        for mapping in lineSplit[1..<lineSplit.count] {
            let numbers = Regex("\\d+").getGreedyMatches(in: mapping).compactMap({ Int($0) })
            mappings.append([numbers[1]..<numbers[1]+numbers[2]:numbers[0]..<numbers[0]+numbers[2]])
        }
        return lineSplit[1..<lineSplit.count].map({
            let numbers = Regex("\\d+").getGreedyMatches(in: $0).compactMap({ Int($0) })
            return [numbers[1]..<numbers[1]+numbers[2]:numbers[0]..<numbers[0]+numbers[2]]
        })
    })
    
//    print(maps)
    var seedRanges: [Range<Int>] = []
    for index in stride(from: 0, to: seeds.count, by: 2) {
        let start = seeds[index]
        let length = seeds[index+1]
        seedRanges.append(start..<start+length)
    }
    print(seedRanges)
    
    var validLocations: [Int] = []
    
    
    
//    var location = Int.max
//    for range in seedRanges {
//        print("Starting \(range)")
//        for seed in range {
//            if seed % 100000 == 0 {
//                print(seed)
//            }
//        
//                //        print("Starting with: \($0)")
//            var currentId = seed
//            
//            for mappingsList in maps {
//                var changed = false
//                for map in mappingsList {
//                    for (sourceRange, destRange) in map {
//                        if sourceRange.contains(currentId) {
//                            //                        print(sourceRange, destRange)
//                            currentId -= sourceRange.lowerBound - destRange.lowerBound
//                            //                        print("Changed to: \(currentId)")
//                            changed = true
//                            break
//                        }
//                    }
//                    if changed { break }
//                }
//            }
//            if currentId < location {
//                location = currentId
//            }
//        }
//    }
//    
//    print(location)
}

Timer.time(main)
