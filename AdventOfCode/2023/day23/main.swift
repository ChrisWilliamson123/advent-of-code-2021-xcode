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
    let neighbours: [Coordinate: Set<Coordinate>]
    let nonWallCoords: Set<Coordinate>
    var junctionCoordinates: Set<Coordinate>
    var junctionDistances: [JunctionPair: Int] = [:]
    var junctionNeighbours: [Coordinate: Set<Coordinate>] = [:]

    lazy var trailStartLocation: Coordinate = {
        Coordinate(grid[0].firstIndex(of: ".")!, 0)
    }()

    lazy var trailEndLocation: Coordinate = {
        Coordinate(grid[grid.count-1].firstIndex(of: ".")!, grid.count - 1)
    }()

    init(grid: [[Character]]) {
        self.grid = grid
        let coordsToChars = grid.coordsToChars
        self.coordsToChars = coordsToChars
        self.allCoords = Set(coordsToChars.keys)

        let nonWallCoords = allCoords.filter({ coordsToChars[$0] != "#" })
        self.nonWallCoords = nonWallCoords
        var neighbours: [Coordinate: Set<Coordinate>] = [:]
        for c in nonWallCoords {
            neighbours[c] = c.getAxialAdjacents(in: grid).filter({ nonWallCoords.contains($0) })
        }
        self.neighbours = neighbours
        self.junctionCoordinates = Set(neighbours.filter({ $0.value.count > 2 }).keys)

        junctionCoordinates.insert(self.trailStartLocation)
        junctionCoordinates.insert(self.trailEndLocation)
    }

    struct Node: Hashable {
        let coordinate: Coordinate
        let depth: Int
        let previous: Set<Coordinate>
    }

    struct JunctionPair: Hashable {
        let juncOne: Coordinate
        let juncTwo: Coordinate
    }

    func getJunctionDistances() -> [JunctionPair: Int] {
        var distances: [JunctionPair: Int] = [:]
        for j in junctionCoordinates {
            for j2 in junctionCoordinates where j2 != j {
                let result = dijkstra(graph: allCoords, source: j, target: j2) { current in
                    var neighbours = self.neighbours[current]!
                    if let toRemove = neighbours.first(where: { self.junctionCoordinates.contains($0) && $0 != j2 }) {
                        neighbours.remove(toRemove)
                    }
                    return neighbours
                } getDistanceBetween: { _, _ in
                    1
                }
                if let distance = result.distances[j2], distance < Int.max {
                    distances[.init(juncOne: j, juncTwo: j2)] = distance
                    distances[.init(juncOne: j2, juncTwo: j)] = distance
                    junctionNeighbours[j, default: []].insert(j2)
                    junctionNeighbours[j2, default: []].insert(j)
                }

            }
        }
        self.junctionDistances = distances
        return distances
    }

    func findLongestDistanceToEnd() -> Int {
        var maxDepth = 0

        var visited: Set<Node> = []
        var queue: [Node] = []

        queue.append(Node(coordinate: trailStartLocation, depth: 0, previous: []))
        visited.insert(Node(coordinate: trailStartLocation, depth: 0, previous: []))
        var index = 0
        var count = 1
        while index < count {
            let current = queue[index]

            let neighbours = self.junctionNeighbours[current.coordinate]!

            for n in neighbours where !current.previous.contains(n) {
                let newNode = Node(coordinate: n,
                                   depth: current.depth + junctionDistances[.init(juncOne: current.coordinate, juncTwo: n)]!,
                                   previous: current.previous.union([current.coordinate]))

                if !visited.contains(newNode) {
                    queue.append(newNode)
                    count += 1
                    visited.insert(newNode)
                    maxDepth = max(maxDepth, newNode.depth)
                }
            }
            index += 1
        }

        return maxDepth
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n")
    let grid = input.map({ [Character]($0) })
    let hikingTrail = HikingTrail(grid: grid)
    _ = hikingTrail.getJunctionDistances()
    let r = hikingTrail.findLongestDistanceToEnd()

    print(r)
}

Timer.time(main)
