import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n\n")
    var tiles: [Tile] = []
    input.forEach({
        let lineSplit = $0.split(separator: "\n")
        let id = lineSplit[0].split(separator: " ")[1].prefix(4)
        tiles.append(.init(grid: lineSplit[1..<lineSplit.count].map({ [Character]($0) }), id: Int(id)!))
    })


    let tile1427 = tiles.first(where: { $0.id == 1427 })!
    typealias EdgeMap = [Tile: [(baseEdge: Edge, neighbour: Tile, neighbourEdge: Edge)]]
//    var attempts: [EdgeMap] = []

    for orientationOf1427 in tile1427.allOrientations {
        var edgeMap: EdgeMap = [orientationOf1427: []]

        var doneTiles: Set<Int> = []
        var incompleteTiles = edgeMap.filter({ !doneTiles.contains($0.key.id) }).keys

        while incompleteTiles.count > 0 {
            let nextBaseTile = incompleteTiles.first!
//            print("Doing tile \(nextBaseTile.id)")

            let otherTiles = tiles.filter({ $0.id != nextBaseTile.id && !doneTiles.contains($0.id) })

            let baseTileEdges = [nextBaseTile.top, nextBaseTile.right, nextBaseTile.bottom, nextBaseTile.left]
            for baseEdgeIndex in 0..<baseTileEdges.count {
                let baseEdgeChars = baseTileEdges[baseEdgeIndex]
                let baseEdgeType = Edge.all[baseEdgeIndex]
                var baseEdgeDone = false
                for otherTile in otherTiles {
                    // Get all orientations
                    let allViableOrientationsOfOtherTile: Set<Tile>
//                    if let alreadyOrientedOtherTile = otherTile.allOrientations.first(where: { edgeMap.keys.contains($0) }) {
//                        allViableOrientationsOfOtherTile = Set([alreadyOrientedOtherTile])
//                    } else {
//                    }
                    allViableOrientationsOfOtherTile = otherTile.allOrientations

                    for orientation in allViableOrientationsOfOtherTile {
                        let edgesForOrientation = [orientation.top, orientation.right, orientation.bottom, orientation.left]

                        for edgeIndex in 0..<edgesForOrientation.count {
                            let edgeChars = edgesForOrientation[edgeIndex]
                            let edgeType = Edge.all[edgeIndex]
                            if edgeChars == baseEdgeChars {
//                                print("\tMatch found: \(otherTile.id)")
                                edgeMap[nextBaseTile] = (edgeMap[nextBaseTile] ?? []) + [(baseEdge: baseEdgeType, neighbour: orientation, neighbourEdge: edgeType)]
                                edgeMap[orientation] = (edgeMap[orientation] ?? []) + [(baseEdge: edgeType, neighbour: nextBaseTile, neighbourEdge: baseEdgeType)]
                                // GOING TO HAVE TO HAVE SOME SORT OF WAY TO CHECK THAT A TILE IS DONE SO I DONT CHECK AGAIN
                                baseEdgeDone = true
                                break
                            }
                        }
                        if baseEdgeDone { break }
                    }

                    if baseEdgeDone { break }
                }
            }

            doneTiles.insert(nextBaseTile.id)
            incompleteTiles = edgeMap.filter({ !doneTiles.contains($0.key.id) }).keys
        }

        for e in edgeMap {
            print(e)
        }

        print("\n")

//        attempts.append(edgeMap)
    }

//    for a in attempts {
//        print("\n")
//        for e in a {
//            print(e)
//        }
//    }

    // NEED TO GET THE ENTRY WITH THE RIGHT EDGES
    // First, get rid of all attempts where there's an edge that has one value

//    var correctAttempts = attempts.filter({ attempt in
//        let valuesForAllEdges = attempt.values
//        let valuesThatHaveOneEdgeEntry = valuesForAllEdges.filter({ $0.count == 1 })
//        if valuesThatHaveOneEdgeEntry.count > 0 {
//            return false
//        }
//        return true
//    })
    // A correct attempt will have four entries where there are two values (the corners)
    // A correct attempt will also have (sqrt(tiles.count) * 4) - 4 entries with three values
//    var correctEntries = attempts.filter({ attempt in
//        let allValues = attempt.values
//        let lengthTwoValues = allValues.filter({ $0.count == 2 })
//        if lengthTwoValues.count == 4 { return true }
//        return false
//    })

//    for a in correctAttempts {
//        print("\n")
//        for e in a {
//            print(e)
//        }
//    }

//    print(print(attempts))

//    let sqRoot = Int(sqrt(Double(tiles.count)))
//    let expectedEdgePieces = (sqRoot * 2) + ((sqRoot - 2) * 2) - 4
//    print(expectedEdgePieces)
//    correctEntries = correctEntries.filter({ attempt in
//        let allValues = attempt.values
//        let threeValues = allValues.filter({ $0.count == 3 })
//        if threeValues.count == expectedEdgePieces { return true }
//        return false
//    })
//
//    print(correctEntries.count)
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

