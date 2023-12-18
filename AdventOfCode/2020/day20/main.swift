import Foundation

func main() throws {
    print(try findSeaMonsters(gridFileName: "full-grid.txt"))
}

private func findSeaMonsters(gridFileName: String) throws -> Int {
    let input: [String] = try readInput(fileName: gridFileName)
    let grid: [[Character]] = input.map({ [Character]($0) })
    assert(grid.count == grid[0].count)

    let tile = Tile(grid: grid, id: 1)

    /// Always assuming we're checking from a monster's head
    func getIndexesToCheckForSeaMonster(root: Coordinate) -> [Coordinate]? {
        // First, check if the area we're checking in is valid
        let xRange = (root.x - 18)...(root.x+1)
        if xRange.lowerBound < 0 || xRange.upperBound >= grid[0].count {
            return nil
        }

        let yRange = root.y...(root.y+2)
        if yRange.lowerBound < 0 || yRange.upperBound >= grid.count {
            return nil
        }

        var coords: [Coordinate] = []

        coords.append(.init(root.x-18, root.y+1))
        coords.append(.init(root.x-13, root.y+1))
        coords.append(.init(root.x-12, root.y+1))
        coords.append(.init(root.x-7, root.y+1))
        coords.append(.init(root.x-6, root.y+1))
        coords.append(.init(root.x-1, root.y+1))
        coords.append(.init(root.x-0, root.y+1))
        coords.append(.init(root.x+1, root.y+1))

        coords.append(.init(root.x-17, root.y+2))
        coords.append(.init(root.x-14, root.y+2))
        coords.append(.init(root.x-11, root.y+2))
        coords.append(.init(root.x-8, root.y+2))
        coords.append(.init(root.x-5, root.y+2))
        coords.append(.init(root.x-2, root.y+2))

        return coords
    }

    let calcWaterRoughness: (Int, [[Character]]) -> Int = { seaMonsterCount, grid in
        return (grid.flatMap({ $0 }).reduce(0, { $1 == "#" ? $0 + 1 : $0 })) - (seaMonsterCount * 15)
    }

    for o in tile.allOrientations {
        var seaMonstersFound = 0
        for y in 0..<o.grid.count {
            for x in 0..<o.grid[y].count {
                let char = o.grid[y][x]
                guard char == "#" else { continue }
                let coord = Coordinate(x, y)
                guard let otherCoordsToCheck = getIndexesToCheckForSeaMonster(root: coord) else { continue }
                // If we find a . then continue
                let firstDot = otherCoordsToCheck.first(where: { o.grid[$0.y][$0.x] == "." })
                if firstDot != nil {
                    continue
                }
                seaMonstersFound += 1
            }
        }
        if seaMonstersFound > 0 {
            return calcWaterRoughness(seaMonstersFound, o.grid)
        }
    }
    return 0
}

private func buildGrid(tiles: Set<Tile>) {
    var edgeMap: [Int: [Edge: (tile: Tile, edge: Edge)]] = [:]

//    for tile in tiles {
//
//        let matches = findMatchesForEdges(of: tile, allTiles: tiles)
//        edgeMap[tile.id] = matches
//        let matchingEdges = matches.values
//        assert(matchingEdges.count < 5 && matchingEdges.count > 1)
//        switch matchingEdges.count {
//        case 2: cornerTileIDs.insert(tile.id)
//        case 3: edgeTileIDs.insert(tile.id)
//        case 4: middleTileIDs.insert(tile.id)
//        default: break
//        }
//    }

    // Get bottom and right for 1951, we want it top left so flip on x axis and get edges again
//    let tile1889 = tiles.first(where: { $0.id == 1889 })!
    let tile1889 = tiles.first(where: { $0.id == 1951 })!.flippedOnX
    let newEdges = findMatchesForEdges(of: tile1889, allTiles: tiles)

    let matchings: [Edge: Edge] = [
        .top: .bottom,
        .right: .left,
        .bottom: .top,
        .left: .right
    ]

    let indexChange: [Edge: (x: Int, y: Int)] = [
        .top: (0, -1),
        .right: (1, 0),
        .bottom: (0, 1),
        .left: (-1, 0)
    ]

    func matchEdge(_ edge: Edge, to edgeChars: [Character], tile: Tile) -> Tile {
        // Lazy, try all orientations
        for orientation in tile.allOrientations where orientation.allEdges[edge] == edgeChars {
            return orientation
        }
        return tile
    }

    var finalMap: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)

    finalMap[0][0] = tile1889
    var xRoot = 0
    var yRoot = 0
    for edge in newEdges {
        let indexChange = indexChange[edge.key]!
        let newX = xRoot + indexChange.x
        let newY = yRoot + indexChange.y
        finalMap[newY][newX] = matchEdge(matchings[edge.key]!, to: tile1889.allEdges[edge.key]!, tile: edge.value.tile)
    }
    print(finalMap[0][1]!.gridString)
    print(finalMap[1][0]!.gridString)

    for y in 0..<finalMap.count {
        print(y)
        for x in 0..<finalMap[0].count {
            let edges = findMatchesForEdges(of: finalMap[y][x]!, allTiles: tiles)
            let xRoot = x
            let yRoot = y
            for edge in edges {
                let indexChange = indexChange[edge.key]!
                let newX = xRoot + indexChange.x
                let newY = yRoot + indexChange.y
                if (newX >= 0 && newX < finalMap.count) && (newY >= 0 && newY < finalMap.count) {
                    finalMap[newY][newX] = matchEdge(matchings[edge.key]!, to: finalMap[y][x]!.allEdges[edge.key]!, tile: edge.value.tile)
                }
            }
        }
    }
    printGrid(finalMap)
}

private func printGrid(_ grid: [[Tile?]]) {
    for yTileIndex in 0..<grid.count {
        var rowsToPrint: [String] = Array(repeating: "", count: 10)
        for xTileIndex in 0..<grid[0].count {
            if let tile = grid[yTileIndex][xTileIndex] {
                for i in 0..<rowsToPrint.count {
                    rowsToPrint[i] += " " + tile.grid[i] + " "
                }
            } else {
                for i in 0..<rowsToPrint.count {
                    rowsToPrint[i] += " XXXXXXXXXX "
                }
            }
        }
        for r in rowsToPrint {
            print(r)
        }
        print("\n")
//        print(row)
    }
}

private func findMatchesForEdges(of tile: Tile, allTiles: Set<Tile>) -> [Edge: (tile: Tile, edge: Edge)] {
    let baseTileEdges = tile.allEdges

    var toReturn: [Edge: (tile: Tile, edge: Edge)] = [:]
    for edge in baseTileEdges {
        if let matchingTileAndEdge = findMatchingTileAndEdge(for: tile, with: edge.value, allTiles: allTiles) {
            toReturn[edge.key] = matchingTileAndEdge
        }
    }
    return toReturn
}

private func findMatchingTileAndEdge(for tile: Tile, with edge: [Character], allTiles: Set<Tile>) -> (tile: Tile, edge: Edge)? {
    var otherTiles = allTiles
    otherTiles.remove(tile)

    for otherTile in otherTiles where otherTile.id != tile.id {
        for otherTileOrientation in otherTile.allOrientations {
            let otherTileEdges = otherTileOrientation.allEdges
            for otherTileEdge in otherTileEdges where otherTileEdge.value == edge {
                return (otherTileOrientation, otherTileEdge.key)
            }
        }
    }

    return nil
}

struct Tile: CustomStringConvertible, Hashable {
    let grid: [[Character]]
    let id: Int

    var numberOfRows: Int { grid.count }
    var numberOfColumns: Int { grid[0].count }
    var allOrientations: Set<Tile> {
        var orientations: Set<Tile> = []
        for rotationsToPerform in 0..<4 {
            var tile = self
            for _ in 0..<rotationsToPerform { tile = tile.rotatedRight }
            orientations.insert(tile)
            orientations.insert(tile.flippedOnX)
            orientations.insert(tile.flippedOnY)
        }

        return orientations
    }
    var top: [Character] { grid[0] }
    var bottom: [Character] { grid[numberOfRows-1] }
    var right: [Character] { (0..<numberOfRows).map({ grid[$0][numberOfColumns-1] }) }
    var left: [Character] { (0..<numberOfRows).map({ grid[$0][0] }) }
    var allEdges: [Edge: [Character]] {
        [
            .top: top,
            .right: right,
            .bottom: bottom,
            .left: left
        ]
    }

    var rotatedRight: Tile {
        var newGrid: [[Character]] = Array(repeating: Array(repeating: " ", count: numberOfColumns), count: numberOfRows)
        // Go through each existing row and fill up the columns of the new one from right to left
        for y in 0..<numberOfRows {
            let rowChars = grid[y]
            // rowChars need to be at the end column
            let columnIndex = numberOfColumns - 1 - y
            for y2 in 0..<numberOfRows {
                newGrid[y2][columnIndex] = rowChars[y2]
            }
        }

        return Tile(grid: newGrid, id: id)
    }

    var rotatedLeft: Tile {
        rotatedRight.rotatedRight.rotatedRight
    }

    var flippedOnY: Tile {
        var newGrid: [[Character]] = Array(repeating: Array(repeating: " ", count: numberOfColumns), count: numberOfRows)

        for y in 0..<numberOfRows {
            for x in 0..<numberOfColumns {
                let char = grid[y][x]
                let newXIndex = numberOfColumns - 1 - x
                newGrid[y][newXIndex] = char
            }
        }

        return Tile(grid: newGrid, id: id)
    }

    var flippedOnX: Tile {
        var newGrid: [[Character]] = Array(repeating: Array(repeating: " ", count: numberOfColumns), count: numberOfRows)

        for y in 0..<numberOfRows {
            for x in 0..<numberOfColumns {
                let char = grid[y][x]
                let newYIndex = numberOfRows - 1 - y
                newGrid[newYIndex][x] = char
            }
        }

        return Tile(grid: newGrid, id: id)
    }

    var description: String {
//        "\(id)\n" + grid.map({ String($0) }).joined(separator: "\n")
        "\(id)"
    }

    var gridString: String {
        grid.map({ String($0) }).joined(separator: "\n")
    }

    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.grid == rhs.grid
    }
}

enum Edge: String, CustomStringConvertible {
    case top
    case right
    case bottom
    case left

    static var all: [Edge] { [.top, .right, .bottom, .left] }
    var description: String { self.rawValue }
}

Timer.time(main)
