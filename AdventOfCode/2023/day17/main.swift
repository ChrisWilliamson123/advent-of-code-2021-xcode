import Foundation

struct PositionWithDirectionCount: Hashable {
    let position: Coordinate
    let direction: Coordinate?
    let directionAmount: Int
}

let leftRights: [Coordinate: Set<Coordinate>] = [
    .right: [.up, .down],
    .left: [.up, .down],
    .down: [.left, .right],
    .up: [.left, .right]
]

private func getNeighboursPart1(current: PositionWithDirectionCount, heatMap: [[Int]]) -> Set<PositionWithDirectionCount> {
    let currentPosition = current.position
    // If we have no current direction, must be at start, so return right and down position
    guard let currentDirection = current.direction else {
        return Set([Coordinate.right, Coordinate.down]
            .map({ PositionWithDirectionCount(position: currentPosition + $0, direction: $0, directionAmount: 1) }))
    }

    // Do left, right, straight
    let neighbours = leftRights[currentDirection]!
        .map({ PositionWithDirectionCount(position: currentPosition + $0, direction: $0, directionAmount: 1) })
    + [PositionWithDirectionCount(position: currentPosition + currentDirection,
                                  direction: currentDirection,
                                  directionAmount: current.directionAmount + 1)]

    // Filter out neighbours whose direction is <=3 and who do not have in-bounds coord
    return Set(neighbours.filter({
        $0.directionAmount <= 3 && $0.position.isIn(heatMap)
    }))
}

private func getNeighboursPart2(current: PositionWithDirectionCount, heatMap: [[Int]]) -> Set<PositionWithDirectionCount> {
    let currentPosition = current.position
    // If we have no current direction, must be at start, so return right and down position
    guard let currentDirection = current.direction else {
        return Set([Coordinate.right, Coordinate.down]
            .map({ PositionWithDirectionCount(position: currentPosition + $0, direction: $0, directionAmount: 1) }))
    }

    // Build all neighbour arrays and then filter out bad ones
    var potentialNeighbours = [PositionWithDirectionCount]()
    // Can only move forward
    if current.directionAmount < 4 {
        potentialNeighbours.append(.init(position: currentPosition + currentDirection,
                                         direction: currentDirection,
                                         directionAmount: current.directionAmount + 1))
    }
    // Can only move left, right
    else if current.directionAmount == 10 {
        potentialNeighbours.append(contentsOf: leftRights[currentDirection]!
            .map({ PositionWithDirectionCount(position: currentPosition + $0, direction: $0, directionAmount: 1) }))
    }
    // Can move straight, left, right
    else {
        potentialNeighbours.append(contentsOf: leftRights[currentDirection]!
            .map({ PositionWithDirectionCount(position: currentPosition + $0, direction: $0, directionAmount: 1) })
                                   + [PositionWithDirectionCount(position: currentPosition + currentDirection,
                                                                 direction: currentDirection,
                                                                 directionAmount: current.directionAmount + 1)]
        )
    }

    // Need to filter out ones who are not in grid and who haven't got the space to go 4 tiles in same direction
    return Set(potentialNeighbours.filter({
        let currentPosition = $0.position
        let currentDirection = $0.direction!
        let movedAmount = $0.directionAmount
        guard currentPosition.isIn(heatMap) else { return false }

        guard movedAmount < 4 else { return true }
        let spaceNeeded = 4 - movedAmount

        switch currentDirection {
        case .right: return (heatMap[0].count - 1) - currentPosition.x >= spaceNeeded
        case .left: return currentPosition.x >= spaceNeeded
        case .down: return (heatMap.count - 1) - currentPosition.y >= spaceNeeded
        case .up: return currentPosition.y >= spaceNeeded
        default: assert(false, "Invalid direction found")
        }
    }))
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let heatMap = input.map({ line in line.map({ Int($0)! }) })

    let startPoint = PositionWithDirectionCount(position: Coordinate(0, 0), direction: nil, directionAmount: 0)
    let endPoint = Coordinate(heatMap[0].count - 1, heatMap.count - 1)

    let neighbourFunctions: [(PositionWithDirectionCount, [[Int]]) -> Set<PositionWithDirectionCount>] = [
        getNeighboursPart1,
        getNeighboursPart2
    ]

    neighbourFunctions.forEach({ neighbourFunc in
        let result = dijkstra2(source: startPoint,
                               target: endPoint,
                               getNeighbours: { neighbourFunc($0, heatMap) },
                               getDistanceBetween: { heatMap[$1.y][$1.x] })

        print(result.distances.filter({ $0.key.position == endPoint }).min(by: { $0.value < $1.value })!.value)
    })
}

private func dijkstra2(source: PositionWithDirectionCount,
                       target: Coordinate?,
                       getNeighbours: (PositionWithDirectionCount) -> Set<PositionWithDirectionCount>,
                       getDistanceBetween: (Coordinate, Coordinate) -> Int) -> (distances: [PositionWithDirectionCount: Int], chain: [PositionWithDirectionCount: PositionWithDirectionCount?]) { // swiftlint:disable:this line_length
    var dist: [PositionWithDirectionCount: Int] = [:]
    var prev: [PositionWithDirectionCount: PositionWithDirectionCount?] = [:]
    var visited: Set<PositionWithDirectionCount> = []
    dist[source] = 0

    var heap = Heap<PositionWithDirectionCount>(priorityFunction: { dist[$0]! < dist[$1]! })

    heap.enqueue(source)

    while !heap.isEmpty {
        let current = heap.dequeue()!
        if let target = target, current.position == target {
            return (dist, prev)

        }
        visited.insert(current)

        let neighbours = getNeighbours(current)
        for neighbour in neighbours where !visited.contains(neighbour) {
            let newDistance = dist[current]! + getDistanceBetween(current.position, neighbour.position)

            if newDistance < dist[neighbour, default: Int.max] {
                dist[neighbour] = newDistance
                prev[neighbour] = current
                if heap.indexMap[neighbour] != nil {
                    heap.changeElement(neighbour, to: neighbour)
                } else {
                    heap.enqueue(neighbour)
                }
            }
        }
    }

    return (dist, prev)
}

Timer.time(main)
