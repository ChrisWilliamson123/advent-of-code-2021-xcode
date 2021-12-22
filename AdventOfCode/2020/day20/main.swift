import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n\n")
    var tiles: Set<Tile> = []
    input.forEach({
        let lineSplit = $0.split(separator: "\n")
        let id = lineSplit[0].split(separator: " ")[1].prefix(4)
        tiles.insert(.init(grid: lineSplit[1..<lineSplit.count].map({ [Character]($0) }), id: Int(id)!))
    })

    print(tiles.count)

    var cornerTileIDs: Set<Int> = []
    var edgeTileIDs: Set<Int> = []
    var middleTileIDs: Set<Int> = []
//    let cornerTileIDs: Set<Int> = [1789, 1187, 1889, 3121]
//    let edgeTileIDs: Set<Int> = [2053, 2647, 2221, 2789, 1861, 3673, 1009, 1427, 1051, 1129, 1453, 1481, 3347, 2549, 2593, 1583, 2297, 1381, 3331, 1523, 1993, 3319, 1741, 3877, 1201, 3803, 3253, 2699, 1571, 1847, 1607, 3361, 2213, 3671, 1321, 2467, 1747, 2861, 3307, 3967]
//    let middleTileIDs: Set<Int> = [2683, 3719, 1097, 2711, 2503, 3797, 1913, 1487, 2017, 2081, 1061, 2381, 2833, 2137, 1597, 2851, 1033, 2113, 3637, 2671, 2677, 3119, 3019, 3491, 3697, 3529, 2243, 2963, 3943, 1933, 2857, 3299, 3821, 1493, 1181, 2129, 1979, 1931, 3499, 2083, 1013, 2557, 2069, 2389, 1543, 3617, 1217, 1039, 1579, 3079, 1901, 3511, 3163, 1277, 2417, 1231, 2311, 2801, 2281, 3631, 1721, 1283, 3181, 1613, 3643, 2357, 2609, 3761, 2819, 2207, 1237, 3041, 1787, 3931, 3623, 3659, 2879, 2777, 3989, 1327, 2803, 2729, 1091, 2099, 1103, 3049, 3301, 1213, 2437, 2351, 1451, 2161, 2339, 3259, 2011, 3727, 1877, 3929, 3691, 2287]

    var edgeMap: [Int: [Edge: (tile: Tile, edge: Edge)]] = [:]

    for tile in tiles {

        let matches = findMatchesForEdges(of: tile, allTiles: tiles)
        edgeMap[tile.id] = matches
        let matchingEdges = matches.values
//        print(matchingEdges)
        assert(matchingEdges.count < 5 && matchingEdges.count > 1)
        switch matchingEdges.count {
        case 2: cornerTileIDs.insert(tile.id)
        case 3: edgeTileIDs.insert(tile.id)
        case 4: middleTileIDs.insert(tile.id)
        default: break
        }
    }

//    print(cornerTileIDs.count)
//    print(edgeTileIDs.count)
//    print(middleTileIDs.count)

    // Get bottom and right for 1951, we want it top left so flip on x axis and get edges again
    let flipped1951 = tiles.first(where: { $0.id == 1951 })!.flippedOnX
    let newEdges = findMatchesForEdges(of: flipped1951, allTiles: tiles)

    let matchings: [Edge: Edge] = [
        .top:    .bottom,
        .right:  .left,
        .bottom: .top,
        .left:   .right
    ]

    let indexChange: [Edge: (x: Int, y: Int)] = [
        .top:    (0, -1),
        .right:  (1, 0),
        .bottom: (0, 1),
        .left:   (-1, 0)
    ]

    func matchEdge(_ edge: Edge, to edgeChars: [Character], tile: Tile) -> Tile {
        // Lazy, try all orientations
        for orientation in tile.allOrientations {
            if orientation.allEdges[edge] == edgeChars {
                return orientation
            }
        }
        return tile
    }

    var finalMap: [[Tile?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)

    finalMap[0][0] = flipped1951
    var xRoot = 0
    var yRoot = 0
    for edge in newEdges {
        let indexChange = indexChange[edge.key]!
        let newX = xRoot + indexChange.x
        let newY = yRoot + indexChange.y
        finalMap[newY][newX] = matchEdge(matchings[edge.key]!, to: flipped1951.allEdges[edge.key]!, tile: edge.value.tile)
    }

    for y in 0..<finalMap.count {
        for x in 0..<finalMap[0].count {
            let edges = findMatchesForEdges(of: finalMap[y][x]!, allTiles: tiles)
            let xRoot = x
            let yRoot = y
            for edge in edges {
                let indexChange = indexChange[edge.key]!
                let newX = xRoot + indexChange.x
                let newY = yRoot + indexChange.y
                finalMap[newY][newX] = matchEdge(matchings[edge.key]!, to: finalMap[y][x]!.allEdges[edge.key]!, tile: edge.value.tile)
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
            for otherTileEdge in otherTileEdges {
                if otherTileEdge.value == edge {
                    return (otherTileOrientation, otherTileEdge.key)
                }
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
            .left: left,
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

try main()

