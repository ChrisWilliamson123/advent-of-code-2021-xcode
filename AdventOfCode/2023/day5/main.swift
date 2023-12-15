import Foundation

struct Map {
    let source: Int
    let destination: Int
    let length: Int
}

private func processSeed(_ seed: Int, maps: [Map]) -> Int {
    for map in maps {
        let range = map.source..<map.source + map.length
        if range.contains(seed) {
            let diff = seed - map.source
            return map.destination + diff
        }
    }
    return seed
}

private func processSeedRangeToMap(_ seedRange: Range<Int>, map: Map) -> (processed: Range<Int>?, unprocessed: [Range<Int>]) {
    let rangeSplitter = RangeSplitter(firstRange: seedRange, secondRange: map.source..<map.source+map.length, modifier: map.destination - map.source)
    let split = rangeSplitter.split()
    return (split.modified, split.unmodified)
}

/*
 Example 79..<93 mapping to 98..<100 (dest 50)
 */
private func processSeedRanges(_ seedRanges: [Range<Int>], maps: [Map]) -> [Range<Int>] {
    var processedRanges: [Range<Int>] = []
    var unprocessedRanges: [Range<Int>] = seedRanges
    
    for m in maps {
        guard !unprocessedRanges.isEmpty else { continue }
        var newlyUnprocessed: [Range<Int>] = []
        for range in unprocessedRanges {
            let (processed, unprocessed) = processSeedRangeToMap(range, map: m)
            newlyUnprocessed += unprocessed
            processed.map { processedRanges.append($0) }
        }
        unprocessedRanges = newlyUnprocessed
    }
    
    return processedRanges + unprocessedRanges
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let seedNumbers = Regex("\\d+").getGreedyMatches(in: input[0]).compactMap({ Int($0) })
    let seedRanges = stride(from: 0, to: seedNumbers.count, by: 2).map({ seedNumbers[$0]..<seedNumbers[$0]+seedNumbers[$0+1] })
    
    let maps = input[1..<input.count].map({
        let ranges = $0.split(separator: "\n")[1...]
        return ranges.map {
            let ints = $0.split(separator: " ").map({ Int($0)! })
            return Map(source: ints[1], destination: ints[0], length: ints[2])
        }
    })
    
    let part1 = seedNumbers.map({ seedNumber in
        maps.reduce(seedNumber, { processSeed($0, maps: $1) })
    })
    print(part1.min()!)
    
    let part2 = maps.reduce(seedRanges, { processSeedRanges($0, maps: $1) }).map({ $0.lowerBound }).min()!
    print(part2)
}

Timer.time(main)
