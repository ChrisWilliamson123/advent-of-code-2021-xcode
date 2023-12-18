import Foundation

enum Direction: String, Hashable {
    case up = "^"
    case down = "v"
    case right = ">"
    case left = "<"
}

enum Space: CustomStringConvertible, Hashable {
    case empty
    case wall
    case blizzard([Direction])

    var description: String {
        switch self {
        case .empty:
            return "."
        case .wall:
            return "#"
        case .blizzard(let directions):
            if directions.count == 1 {
                return directions[0].rawValue
            }
            return String(directions.count)
        }
    }
}

struct Valley: Hashable {
    let grid: [[Space]]
    let directions: [Coordinate: [Direction]]

    init(grid: [[Space]]) {
        self.grid = grid
        var directions = [Coordinate: [Direction]]()
        for y in 0..<grid.count {
            for x in 0..<grid[y].count {
                let coord = Coordinate(x, y)
                let space = grid[y][x]
                if case let .blizzard(ds) = space {
                    directions[coord] = ds
                }
            }
        }
        self.directions = directions
    }

    func printGrid() {
        for y in 0..<grid.count {
            var toPrint = ""
            for x in 0..<grid[y].count {
                toPrint += grid[y][x].description
            }
            print(toPrint)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func getNextState() -> Valley {
        var newDirections = [Coordinate: [Direction]]()
        for (coordinate, ds) in directions {
            for direction in ds {
                switch direction {
                case .down:
                    var nextY = coordinate.y + 1
                    if nextY > grid.count - 2 {
                        nextY = 1
                    }
                    if newDirections[Coordinate(coordinate.x, nextY)] != nil {
                        newDirections[Coordinate(coordinate.x, nextY)]!.append(direction)
                    } else {
                        newDirections[Coordinate(coordinate.x, nextY)] = [direction]
                    }
                case .up:
                    var nextY = coordinate.y - 1
                    if nextY < 1 {
                        nextY = grid.count-2
                    }
                    if  newDirections[Coordinate(coordinate.x, nextY)] != nil {
                        newDirections[Coordinate(coordinate.x, nextY)]!.append(direction)
                    } else {
                        newDirections[Coordinate(coordinate.x, nextY)] = [direction]
                    }
                case .right:
                    var nextX = coordinate.x + 1
                    if nextX > grid[0].count - 2 {
                        nextX = 1
                    }
                    if newDirections[Coordinate(nextX, coordinate.y)] != nil {
                        newDirections[Coordinate(nextX, coordinate.y)]!.append(direction)
                    } else {
                        newDirections[Coordinate(nextX, coordinate.y)] = [direction]
                    }
                case .left:
                    var nextX = coordinate.x - 1
                    if nextX < 1 {
                        nextX = grid[0].count - 2
                    }
                    if newDirections[Coordinate(nextX, coordinate.y)] != nil {
                        newDirections[Coordinate(nextX, coordinate.y)]!.append(direction)
                    } else {
                        newDirections[Coordinate(nextX, coordinate.y)] = [direction]
                    }
                }
            }
        }
        var newGrid: [[Space]] = []
        for y in 0..<grid.count {
            var row: [Space] = []
            for x in 0..<grid[y].count {
                let current = grid[y][x]
                if current == .wall {
                    row.append(.wall)
                    continue
                }
                let coord = Coordinate(x, y)
                if let direction = newDirections[coord] {
                    row.append(.blizzard(direction))
                } else {
                    row.append(.empty)
                }
            }
            newGrid.append(row)
        }
        assert(newGrid.count == grid.count)
        assert(newGrid[0].count == grid[0].count)
        return Valley(grid: newGrid)
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let grid = input.map({ line in line.map({ character in
        if character == "#" {
            return Space.wall
        }
        if character == "." {
            return Space.empty
        }
        return Space.blizzard([.init(rawValue: String(character))!])
    }) })

    var coords: Set<Coordinate> = []
    for y in 0..<grid.count {
        for x in 0..<grid[y].count {
            coords.insert(.init(x, y))
        }
    }
    var valley = Valley(grid: grid)

    // preload states
    var states: [Valley] = []
    states.append(valley)
    for _ in 1..<1000 {
        valley = valley.getNextState()
        states.append(valley)
    }
    let start = Coordinate(1, 0)
    let end = Coordinate(grid[0].count - 2, grid.count - 1)
    struct State: Hashable {
        let steps: Int
        let position: Coordinate
    }

    func bfs(start: Coordinate, end: Coordinate, startTime: Int = 0) -> Int {
        var explored: Set<State> = []
        var frontier = [State(steps: startTime, position: start)]
        while !frontier.isEmpty {
            let currentState = frontier.popLast()!
            let time = currentState.steps + 1
            let position = currentState.position
            let nextState = states[time]
            let adjacents = position.getAxialAdjacents(in: grid, includingSelf: true)
            let nextPositions = adjacents.filter({ nextState.grid[$0.y][$0.x] == .empty })
            for next in nextPositions {
                let state = State(steps: time, position: next)
                if !explored.contains(state) {
                    if next == end {
                        return time
                    }

                    explored.insert(state)
                    frontier.insert(state, at: 0)
                }
            }

        }
        return -1
    }
    let result = bfs(start: start, end: end)
    print(result)
    let back = bfs(start: end, end: start, startTime: result)
    let again = bfs(start: start, end: end, startTime: back)
    print(again)
}

Timer.time(main)
