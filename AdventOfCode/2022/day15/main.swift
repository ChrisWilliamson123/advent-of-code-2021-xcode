import Foundation

struct Beacon {
    let position: Coordinate
    let closestBeaconPosition: Coordinate
    let manhattanDistance: Int

    func getYBlockedRange(for y: Int) -> ClosedRange<Int>? {
        let yDiff = abs(position.y - y)
        if abs(yDiff) > manhattanDistance { return nil }

        let movement = manhattanDistance - yDiff
        return (position.x - movement)...(position.x + movement)
    }
}

func main() throws {

    let input: [String] = try readInput(fromTestFile: false)

    let beacons = input.map {
        let regex = Regex("(-?\\d+)")
        let matches = regex.getGreedyMatches(in: $0).compactMap(Int.init)
        let position = Coordinate(matches[0], matches[1])
        let beacon = Coordinate(matches[2], matches[3])
        return Beacon(position: position, closestBeaconPosition: beacon, manhattanDistance: position.getManhattanDistance(to: beacon))
    }

    let partOneBlockedRanges = beacons.compactMap({ $0.getYBlockedRange(for: 10) })
    print(partOneBlockedRanges.map({ $0.upperBound }).max()! - partOneBlockedRanges.map({ $0.lowerBound }).min()!)

    let upperBound = 4000000
    var found = false
    for y in 0...upperBound {
        let blockedRanges = beacons.compactMap({ $0.getYBlockedRange(for: y) })
            .map({ $0.clamped(to: 0...upperBound) })
            .sorted(by: { $0.lowerBound < $1.lowerBound })

        for i in (blockedRanges.firstIndex(where: { $0.lowerBound > 0 }) ?? 0)..<blockedRanges.count {
            let currentRange = blockedRanges[i]
            if !blockedRanges[0..<i].contains(where: { $0.contains(currentRange.lowerBound-1) }) {
                print(((currentRange.lowerBound - 1) * 4000000) + y)
                found = true
                break
            }
        }
        if found {
            break
        }
    }
}

Timer.time(main)
