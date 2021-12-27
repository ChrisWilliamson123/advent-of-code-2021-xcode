import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    let heightMap = HeightMap(input)

    let lowPoints = heightMap.getLowPoints()
    let riskLevels = lowPoints.map({ heightMap.getRiskLevel(for: $0) })
    print("Part 1: \(riskLevels.sum())")

    let basinSizes: [Int] = lowPoints.map({ heightMap.getBasinCoords(startingAt: $0).count })
    let sorted: [Int] = basinSizes.sorted()
    print("Part 2: \(sorted[sorted.count-3..<sorted.count].reduce(1, *))")
}

struct HeightMap {
    let map: [[Int]]

    init(_ input: [String]) {
        map = input.map({ inputString in [Character](inputString).map({ character in Int(character)! }) })
    }

    func getBasinCoords(startingAt coordinate: Coordinate) -> Set<Coordinate> {
        var explored: Set<Coordinate> = []

        func dfs(_ coord: Coordinate) {
            explored.insert(coord)

            let validAxialEdges = coord.getAxialAdjacents(in: map).filter({ self.getHeight(for: $0) != 9 })

            for edge in validAxialEdges where !explored.contains(edge) {
                dfs(edge)
            }
        }

        dfs(coordinate)

        return explored
    }

    func getLowPoints() -> [Coordinate] {
        var lowPoints: [Coordinate] = []
        for y in 0..<map.count {
            for x in 0..<map[y].count {
                let coordinate = Coordinate(x, y)
                if isLowPoint(coordinate) {
                    lowPoints.append(coordinate)
                }
            }
        }

        return lowPoints
    }

    func getRiskLevel(for coordinate: Coordinate) -> Int {
        getHeight(for: coordinate) + 1
    }

    private func isLowPoint(_ coordinate: Coordinate) -> Bool  {
        let adjacents = coordinate.getAdjacents(in: map)
        let adjacentValues = adjacents.map({ getHeight(for: $0) })
        let coordinateValue = getHeight(for: coordinate)

        for av in adjacentValues {
            if av <= coordinateValue {
                return false
            }
        }

        return true
    }

    private func getHeight(for coordinate: Coordinate) -> Int {
        map[coordinate.y][coordinate.x]
    }
}

try main()
