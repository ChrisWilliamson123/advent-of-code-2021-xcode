import Foundation

class Cave {
    private var rockPositions: Set<Coordinate>
    private var sandPositions: Set<Coordinate> = []
    private var populatedPositions: Set<Coordinate>
    private let sandEntryPosition = Coordinate(500, 0)
    private let floorYPosition: Int

    var sandGrainsPresent: Int { sandPositions.count }

    init(lines: [String]) {
        rockPositions = lines.reduce(into: [], { (positionSet, line) in
            let coords = line.components(separatedBy: " -> ").map {
                let split = $0.components(separatedBy: ",")
                return Coordinate(Int(split[0])!, Int(split[1])!)
            }

            for i in 1..<coords.count {
                let current = coords[i]
                let prev = coords[i-1]
                prev.getLineTo(current)?.forEach { positionSet.insert($0) }
            }
        })
        populatedPositions = rockPositions
        floorYPosition = rockPositions.map({ $0.y }).max()! + 2
    }

    func fillUntilAbyssReached() {
        var currentSandPosition = sandEntryPosition
        while populatedPositions.contains(where: { $0.x == currentSandPosition.x && $0.y > currentSandPosition.y }) {
            let attemptedDestinations = [Coordinate(0, 1)+currentSandPosition, Coordinate(-1, 1)+currentSandPosition, Coordinate(1, 1)+currentSandPosition]
            if let allowedDestination = attemptedDestinations.first(where: { !populatedPositions.contains($0) }) {
                currentSandPosition = allowedDestination
                continue
            }

            populatedPositions.insert(currentSandPosition)
            sandPositions.insert(currentSandPosition)
            currentSandPosition = sandEntryPosition
        }
    }

    func fillUntilFull() {
        var currentSandPosition = sandEntryPosition
        while !sandPositions.contains(sandEntryPosition) {
            if currentSandPosition.y == floorYPosition - 1 {
                sandPositions.insert(currentSandPosition)
                populatedPositions.insert(currentSandPosition)
                currentSandPosition = sandEntryPosition
                continue
            }

            let attemptedDestinations = [Coordinate(0, 1)+currentSandPosition, Coordinate(-1, 1)+currentSandPosition, Coordinate(1, 1)+currentSandPosition]
            if let allowedDestination = attemptedDestinations.first(where: { !populatedPositions.contains($0) }) {
                currentSandPosition = allowedDestination
                continue
            }

            populatedPositions.insert(currentSandPosition)
            sandPositions.insert(currentSandPosition)
            currentSandPosition = sandEntryPosition
        }
    }

    func reset() {
        sandPositions.removeAll()
        populatedPositions = rockPositions
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let cave = Cave(lines: input)
    cave.fillUntilAbyssReached()
    print(cave.sandGrainsPresent)
    cave.reset()
    cave.fillUntilFull()
    print(cave.sandGrainsPresent)
}

Timer.time(main)
