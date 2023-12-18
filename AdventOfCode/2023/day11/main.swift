import Foundation
import Algorithms

struct SpaceCoordinate {
    let isGalaxy: Bool
    let coordinate: Coordinate
}

struct Universe {
    let grid: [[Character]]

    func isRowEmpty(_ rowIndex: Int) -> Bool {
        !grid[rowIndex].contains("#")
    }

    func isColumnEmpty(grid: [[Character]], _ colIndex: Int) -> Bool {
        let column = grid.map({ $0[colIndex] })
        return !column.contains("#")
    }

    var expandedRows: Set<Int> {
        grid.indices.reduce(into: Set<Int>(), { if isRowEmpty($1) { $0.insert($1) } })
    }

    var expandedColumns: Set<Int> {
        grid[0].indices.reduce(into: Set<Int>(), { partial, colIndex in
//            let column = grid.map({ row in row[colIndex] })
            if isColumnEmpty(grid: grid, colIndex) { partial.insert(colIndex) }
        })
    }

    var expanded: Universe {
        // Do rows first
        var newGrid: [[Character]] = []

        for (y, row) in grid.enumerated() {
            newGrid.append(row)
            if isRowEmpty(y) {
                newGrid.append(row)
            }
        }

        var x = 0
        while x < newGrid[0].count {
            if isColumnEmpty(grid: newGrid, x) {
                for y in 0..<newGrid.count {
                    newGrid[y].insert(newGrid[y][x], at: x)
                }
                x += 1
            }
            x += 1
        }
        return Universe(grid: newGrid)
    }

    var galaxyCoordinates: Set<Coordinate> {
        var coordinates = Set<Coordinate>()
        for (y, row) in grid.enumerated() {
            for(x, character) in row.enumerated() where character == "#" {
                coordinates.insert(Coordinate(x, y))
            }
        }
        return coordinates
    }

    var allCoords: Set<Coordinate> {
        var coordinates = Set<Coordinate>()
        for (y, row) in grid.enumerated() {
            for x in row.indices {
                coordinates.insert(Coordinate(x, y))
            }
        }
        return coordinates
    }

    func print() {
        for row in grid {
            Swift.print(row.map({ String($0) }).joined())
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")

    let grid = input.map({ [Character]($0) })
    let galaxy = Universe(grid: grid)
    let expanded = galaxy.expanded

    let galaxyPairs = expanded.galaxyCoordinates.combinations(ofCount: 2)

    let part1 = galaxyPairs.reduce(0) { partialResult, pair in
        let source = pair[0]
        let destination = pair[1]

        return partialResult + source.getManhattanDistance(to: destination)
    }

    print(part1)

    let expandedRows = galaxy.expandedRows
    let expandedColumns = galaxy.expandedColumns
    print(expandedRows)
    print(expandedColumns)

    let expansionFactor = 1000000 - 1
    let part2 = galaxy.galaxyCoordinates.combinations(ofCount: 2).reduce(0) { partialResult, pair in
        let source = pair[0]
        let destination = pair[1]

        let lowY = min(source.y, destination.y)
        let maxY = max(source.y, destination.y)

        let lowX = min(source.x, destination.x)
        let maxX = max(source.x, destination.x)

        let yRange = lowY...maxY
        let xRange = lowX...maxX

        var yDistance = yRange.count-1
        for i in yRange where expandedRows.contains(i) {
            yDistance += expansionFactor
        }

        var xDistance = xRange.count-1
        for i in xRange where expandedColumns.contains(i) {
            xDistance += expansionFactor
        }

        print(source, destination, xRange, xDistance, yDistance)
        return partialResult + xDistance + yDistance
    }

    print(part2)
}

Timer.time(main)
