import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let partOne = buildCave(from: input)
    let partOneResult = aStar(graph: partOne.coords,
                              source: Coordinate(0, 0),
                              target: Coordinate(partOne.cave.count-1, partOne.cave.count-1),
                              getNeighbours: { $0.getAxialAdjacents(in: partOne.cave) },
                              getDistanceBetween: { partOne.cave[$1.y][$1.x] },
                              heuristicFunction: { $0.getManhattanDistance(to: $1) })

    print("Part one:", partOneResult.distances[Coordinate(partOne.cave.count-1, partOne.cave.count-1)]!)

    let partTwo = buildCave(from: input, multiplier: 5)
    let partTwoResult = dijkstra(graph: partTwo.coords,
                          source: Coordinate(0, 0),
                          target: Coordinate(partTwo.cave.count-1, partTwo.cave.count-1),
                          getNeighbours: { $0.getAxialAdjacents(in: partTwo.cave) },
                          getDistanceBetween: { partTwo.cave[$1.y][$1.x] })

    print("Part two:", partTwoResult.distances[Coordinate(partTwo.cave.count-1, partTwo.cave.count-1)]!)
}

private func buildCave(from input: [String], multiplier: Int = 1) -> (cave: [[Int]], coords: Set<Coordinate>) {
    var cave: [[Int]] = []
    var coords: Set<Coordinate> = []

    for y in 0..<input.count*multiplier {
        var caveRow: [Int] = []
        for x in 0..<input[0].count*multiplier {
            let properXIndex = x % input[0].count
            let xAdjustment = x / input[0].count
            let properYIndex = y % input.count
            let yAdjustment = y / input.count
            let adjustment = xAdjustment + yAdjustment

            var value = Int(input[properYIndex][properXIndex])!

            if value + adjustment > 9 {
                value = (value + adjustment) % 9
            } else {
                value += adjustment
            }
            caveRow.append(value)
            let coord = Coordinate(x, y)
            coords.insert(coord)
        }
        cave.append(caveRow)
    }

    return (cave, coords)
}


func euclidianDistance(source: Coordinate, end: Coordinate) -> Double {
    let dx = end.x - source.x
    let dy = end.y - source.y
    return sqrt(Double((dx*dx) + (dy*dy)))
}

Timer.time(main)
