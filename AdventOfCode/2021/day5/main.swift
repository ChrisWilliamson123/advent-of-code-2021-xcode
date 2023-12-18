import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let vents = buildVents(from: input)
    print("Part 1: \(getOverlappedCoordCount(from: vents, onlyCheckAxialVents: true))")
    print("Part 2: \(getOverlappedCoordCount(from: vents))")
}

private func buildVents(from input: [String]) -> [Vent] {
    input.map({ ventString in
        let split = ventString.components(separatedBy: " -> ")
        let startSplit = split[0].split(separator: ",").compactMap({ Int($0) })
        let endSplit = split[1].split(separator: ",").compactMap({ Int($0) })
        return Vent(start: .init(x: startSplit[0], y: startSplit[1]), end: .init(x: endSplit[0], y: endSplit[1]))
    })
}

private func getOverlappedCoordCount(from vents: [Vent], onlyCheckAxialVents: Bool = false) -> Int {
    let vents = onlyCheckAxialVents ? vents.filter({ $0.isAxial }) : vents

    var coordCoverCounts: [Vent.Coordinate: Int] = [:]
    vents.forEach({
        $0.coordsCovered.forEach({ coordCoverCounts[$0] = coordCoverCounts[$0, default: 0] + 1  })
    })

    let coordsCoveredMoreThanOnce = coordCoverCounts.filter({ $1 > 1 })
    return coordsCoveredMoreThanOnce.count
}

struct Vent {
    let start: Coordinate
    let end: Coordinate

    var isAxial: Bool {
        start.x == end.x || start.y == end.y
    }

    var coordsCovered: [Coordinate] {
        let difference = Coordinate(x: end.x - start.x, y: end.y - start.y)
        let magnitude = difference.x == 0 ? difference.y : difference.x
        var pathedCoords: [Coordinate] = []
        var currentCoord = start
        for _ in (0..<abs(magnitude)) {
            pathedCoords.append(Coordinate(x: currentCoord.x + (difference.x / abs(magnitude)), y: currentCoord.y + (difference.y / abs(magnitude))))
            currentCoord = pathedCoords.last!
        }
        return [start] + pathedCoords
    }

    struct Coordinate: Hashable {
        let x: Int
        let y: Int
    }
}

Timer.time(main)
