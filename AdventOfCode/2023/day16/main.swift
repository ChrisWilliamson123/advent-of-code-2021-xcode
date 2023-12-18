import Foundation

let newDirections: [Character: [Coordinate: Set<Coordinate>]] = [
    ".": [.right: [.right], .left: [.left], .down: [.down], .up: [.up]],
    "\\": [.right: [.down], .left: [.up], .down: [.right], .up: [.left]],
    "/": [.right: [.up], .left: [.down], .down: [.left], .up: [.right]],
    "-": [.right: [.right], .left: [.left], .down: [.left, .right], .up: [.left, .right]],
    "|": [.right: [.up, .down], .left: [.up, .down], .down: [.down], .up: [.up]]
]

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n")
    let grid = input.map({ [Character]($0) })

    struct DirectedCoordinate: Hashable, CustomStringConvertible {
        let position: Coordinate
        let direction: Coordinate

        var description: String {
            "(\(position), \(direction))"
        }

        init(_ position: Coordinate, _ direction: Coordinate) {
            self.position = position
            self.direction = direction
        }
    }

    func energise(start: DirectedCoordinate) -> Int {
        let result = bfs(graph: [],
                         source: start,
                         target: nil as Set<DirectedCoordinate>?,
                         getNeighbours: { current in
            let next = current.position + current.direction
            if !next.isIn(grid) {
                return []
            }
            let nextChar = grid[next.y][next.x]

            let newDirectons = newDirections[nextChar]![current.direction]!
            return newDirectons.reduce(into: [], { $0.insert(.init(next, $1)) })
        },
                         getDistanceBetween: { $0.position.getManhattanDistance(to: $1.position) })

        let visitedDirectedCoordsMinusStart = Set(result.prev.keys)
        let visitedCoordinates = visitedDirectedCoordsMinusStart.map({ $0.position })
        return Set(visitedCoordinates).count
    }

    print(energise(start: DirectedCoordinate(Coordinate(-1, 0), Coordinate(1, 0))))

    var p2 = 0
    for yIndex in 0..<grid.count {
        for start in [DirectedCoordinate(Coordinate(-1, yIndex), Coordinate(1, 0)),
                      DirectedCoordinate(Coordinate(grid[0].count, yIndex), Coordinate(-1, 0))] {
            let result = energise(start: start)
            p2 = max(p2, result)
        }
    }

    for xIndex in 0..<grid[0].count {
        for start in [DirectedCoordinate(Coordinate(xIndex, -1), Coordinate(0, 1)),
                      DirectedCoordinate(Coordinate(xIndex, grid.count), Coordinate(0, -1))] {
            let result = energise(start: start)
            p2 = max(p2, result)
        }
    }

    print(p2)
}

Timer.time(main)
