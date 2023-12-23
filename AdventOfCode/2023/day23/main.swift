import Foundation

enum Slope: Character {
    case north = "^"
    case east = ">"
    case south = "v"
    case west = "<"

    var pushDirection: Coordinate {
        switch self {
        case .north: return .north
        case .east: return .east
        case .south: return .south
        case .west: return .west
        }
    }
}

class HikingTrail {
    let grid: [[Character]]
    let coordsToChars: [Coordinate: Character]
    let allCoords: Set<Coordinate>
    var neighbours: [Coordinate: Set<Coordinate>] = [:]
    let nonWallCoords: Set<Coordinate>

    var trailStartLocation: Coordinate {
        Coordinate(grid[0].firstIndex(of: ".")!, 0)
    }

    var trailEndLocation: Coordinate {
        Coordinate(grid[grid.count-1].firstIndex(of: ".")!, grid.count - 1)
    }

    var topologicallySorted: [Coordinate] {
        var visited: Set<Coordinate> = []
        var sortedNodes: [Coordinate] = []

        func visit(_ coord: Coordinate) {
            if !visited.contains(coord) {
                print(coord)
                visited.insert(coord)
                
                let nonWallAdjacents = coord.getAxialAdjacents(in: grid).filter({ coordsToChars[$0] != "#" })
                var neighbours: Set<Coordinate> = []
                for adjacent in nonWallAdjacents {
                    let char = coordsToChars[adjacent]!
                    if let slope = Slope(rawValue: char) {
                        neighbours.insert(adjacent + slope.pushDirection)
                    } else {
                        neighbours.insert(adjacent)
                    }
                }

                for n in neighbours {
                    visit(n)
                }
                sortedNodes.append(coord)
            }
        }

        for coord in allCoords.filter({ coordsToChars[$0] == "." }).sorted(by: { $0.y < $1.y }, { $0.x < $1.x }) {
            visit(coord)
        }

        return sortedNodes
    }

    init(grid: [[Character]]) {
        self.grid = grid
        let coordsToChars = grid.coordsToChars
        self.coordsToChars = coordsToChars
        self.allCoords = Set(coordsToChars.keys)

        self.nonWallCoords = allCoords.filter({ coordsToChars[$0] != "#" })
    }

    struct Node: Hashable {
        let coordinate: Coordinate
        let depth: Int
        let previous: Set<Coordinate>
    }

//    struct CurrentAndPrevious: Hashable {
//        let coordinate:
//    }
    func findLongestDistanceToEnd() -> Node {

        var visited: Set<Node> = []
        var queue: [Node] = []

        queue.append(Node(coordinate: trailStartLocation, depth: 0, previous: []))
        visited.insert(Node(coordinate: trailStartLocation, depth: 0, previous: []))
        var prevDepth = -1
        while !queue.isEmpty {
            // clear up the visited nodes
            for v in visited {
                if v.previous.count == self.nonWallCoords.count - 1 {
                    print("here")
                }
            }

            let current = queue.removeFirst()
//            print(current.depth)
            if current.depth != prevDepth {
                prevDepth = current.depth
                print(prevDepth)
            }

            var neighbours: Set<Coordinate> = []
            if let cached = self.neighbours[current.coordinate] {
                neighbours = cached
            } else {
                neighbours = current.coordinate.getAxialAdjacents(in: grid).intersection(self.nonWallCoords)
//                for adjacent in nonWallAdjacents {
//                    let char = coordsToChars[adjacent]!
//                    if let slope = Slope(rawValue: char) {
//                        neighbours.insert(adjacent + slope.pushDirection)
//                    } else {
//                        neighbours.insert(adjacent)
//                    }
//                }
                self.neighbours[current.coordinate] = neighbours
            }

            for n in neighbours where !current.previous.contains(n) {
                let newNode = Node(coordinate: n,
                                   depth: current.depth + 1,
                                   previous: current.previous.union([current.coordinate]))
                if !visited.contains(newNode) {
                    queue.append(newNode)
                    visited.insert(newNode)
                }
            }
        }

        return visited.filter({ $0.coordinate == trailEndLocation }).max(by: { $0.previous.count < $1.previous.count })!
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let grid = input.map({ [Character]($0) })
    let hikingTrail = HikingTrail(grid: grid)

    let r = hikingTrail.findLongestDistanceToEnd()
    print(r.depth)
    print(r.previous.count)

//    for y in 0..<hikingTrail.grid.count {
//        var row = ""
//        for x in 0..<hikingTrail.grid[0].count {
//            let coord = Coordinate(x, y)
//            if r.previous.contains(coord) {
//                row += "O"
//            } else if hikingTrail.nonWallCoords.contains(coord) {
//                row += "."
//            } else {
//                row += "#"
//            }
//        }
//        print(row)
//    }
}

// 1638 too low

Timer.time(main)
