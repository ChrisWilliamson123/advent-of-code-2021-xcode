import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n")
    let grid = input.map({ [Character]($0) })

    var coordsToChars: [Coordinate: Character] = [:]
    var start: Coordinate!

    for (y, row) in grid.enumerated() {
        for (x, character) in row.enumerated() {
            let coordinate = Coordinate(x, y)
            coordsToChars[coordinate] = character
            if character == "S" {
                start = coordinate
            }
        }
    }

    let part1 = gol(start, grid: grid, chars: coordsToChars, steps: 5000)
    print(part1)
}

struct Node: Hashable {
    let coordinate: Coordinate
    let depth: Int
}

struct OffsetNode: Hashable {
    let relativeCoordinate: Coordinate
    let offset: Coordinate
}

private func createGrids(from offsetNodes: Set<OffsetNode>, initialOffset: Coordinate) -> [Coordinate: Set<Coordinate>] {
    offsetNodes.reduce(into: [:]) { partialResult, offsetNode in
        if partialResult[offsetNode.offset + initialOffset] != nil {
            partialResult[offsetNode.offset + initialOffset]!.insert(offsetNode.relativeCoordinate)
        } else {
            partialResult[offsetNode.offset + initialOffset] = [offsetNode.relativeCoordinate]
        }
    }
}

private func gol(_ start: Coordinate, grid: [[Character]], chars: [Coordinate: Character], steps: Int) -> Int {
    var grids: [Coordinate: Set<Coordinate>] = [.zero: [start]]
    var neighboursCache: [Coordinate: Set<OffsetNode>] = [:]
    var nextGridCache: [Set<Coordinate>: Set<OffsetNode>] = [:]
//    var cache: [Coordinate: Set<GoLNode>] = [:]
//    var alive: Set<GoLNode> = [node]
    var remaining = steps
//    var diffs: [(Int, Int, Double)] = [(0, 0, 0)]
    while remaining > 0 {
        print(remaining)
        var newGrids: [Coordinate: Set<Coordinate>] = [:]
//        var newAlive: Set<GoLNode> = []

        for (gridOffset, relativeCoordinates) in grids {
            // Need to get a set of offset coordinates for this grid
            if let cachedNextGrid = nextGridCache[relativeCoordinates] {
//                print("cache hit!")
                // We have a cache hit, so create the grid from these offset coordinates
                let grids = createGrids(from: cachedNextGrid, initialOffset: gridOffset)
                newGrids.merge(grids, uniquingKeysWith: { $0.union($1) })
                continue
            }

            // We do not have a cache hit, so we need to find the neighbours for each element in the grid
            var newGridOffsetCoords: Set<OffsetNode> = []
            for coordinate in relativeCoordinates {
                if let cached = neighboursCache[coordinate] {
                    newGridOffsetCoords = newGridOffsetCoords.union(cached)
                    continue
                }
                var newCoords = Set<OffsetNode>()
                for d in [Coordinate.north, Coordinate.east, Coordinate.south, Coordinate.west] {
                    var new = coordinate + d
                    var offset: Coordinate = .zero
                    if !new.isIn(grid) {
                        switch d {
                        case .north:
                            new = Coordinate(new.x, grid.count - 1)
                            offset = Coordinate(0, -1)
                        case .east:
                            new = Coordinate(0, new.y)
                            offset = Coordinate(1, 0)
                        case .south:
                            new = Coordinate(new.x, 0)
                            offset = Coordinate(0, 1)
                        case .west:
                            new = Coordinate(grid[0].count - 1, new.y)
                            offset = Coordinate(-1, 0)
                        default: assert(false, "Invalid")
                        }
                    }
                    if chars[new]! == "." || chars[new]! == "S" {
                        newCoords.insert(.init(relativeCoordinate: new, offset: offset))
                        newGridOffsetCoords.insert(.init(relativeCoordinate: new, offset: offset))
                    }
                }
                neighboursCache[coordinate] = newCoords
            }
            nextGridCache[relativeCoordinates] = newGridOffsetCoords
            let grids = createGrids(from: newGridOffsetCoords, initialOffset: gridOffset)
            newGrids.merge(grids, uniquingKeysWith: { $0.union($1) })
        }

        grids = newGrids
        remaining -= 1

    }

    print(grids.reduce(0, { $0 + $1.value.count }))
    return 1
}

Timer.time(main)
