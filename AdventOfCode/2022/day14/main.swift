import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true)
    print(input)
    var rockPathCoords: Set<Coordinate> = []
    for line in input {
        let coords = line.components(separatedBy: " -> ").map {
            let split = $0.components(separatedBy: ",")
            return Coordinate(Int(split[0])!, Int(split[1])!)
        }

        for i in 1..<coords.count {
            let current = coords[i]
            let prev = coords[i-1]
            rockPathCoords.insert(prev)
            rockPathCoords.insert(current)
            let diff = Coordinate(current.x - prev.x, current.y - prev.y)
            if diff.x != 0 {
                for j in min(diff.x, 0)...max(diff.x, 0) {
                    rockPathCoords.insert(Coordinate(prev.x + j, prev.y))
                }
            } else {
                for j in min(diff.y, 0)...max(diff.y, 0) {
                    rockPathCoords.insert(Coordinate(prev.x, prev.y + j))
                }
            }
        }
    }

    let sandEntry = Coordinate(500, 0)
    var sandCoords: Set<Coordinate> = []
    var takenCoords: Set<Coordinate> = rockPathCoords
    var currentSandPosition: Coordinate = Coordinate(500, 0)
    let maxY = rockPathCoords.map({ $0.y }).max()! + 2
    print(maxY)
//    while takenCoords.contains(where: { $0.x == currentSandPosition.x && $0.y > currentSandPosition.y }) {
    while !sandCoords.contains(Coordinate(500, 0)) {
//        let union = sandCoords.union(rockPathCoords)
        if currentSandPosition.y == maxY - 1 {
            sandCoords.insert(currentSandPosition)
            takenCoords.insert(currentSandPosition)
            currentSandPosition = Coordinate(500, 0)
            continue
        }

        // attempt to move the sand down one
        let downOne = currentSandPosition + Coordinate(0, 1)
        if !takenCoords.contains(downOne) {
            // Sand moves down one but doesn't settle
            currentSandPosition = downOne
            continue
        }

        // attempt to move down-left
        let downOneLeft = currentSandPosition + Coordinate(-1, 1)
        if !takenCoords.contains(downOneLeft) {
            // Sand moves down one-left but doesn't settle
            currentSandPosition = downOneLeft
            continue
        }

        // attempt to move down-right
        let downOneRight = currentSandPosition + Coordinate(1, 1)
        if !takenCoords.contains(downOneRight) {
            // Sand moves down one-right but doesn't settle
            currentSandPosition = downOneRight
            continue
        }

        // Sand cannot move, so it must settle
        takenCoords.insert(currentSandPosition)
        sandCoords.insert(currentSandPosition)
        currentSandPosition = Coordinate(500, 0)
    }

    print(sandCoords.count)
}

Timer.time(main)
