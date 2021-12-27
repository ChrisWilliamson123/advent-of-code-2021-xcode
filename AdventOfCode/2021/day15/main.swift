import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var cave: [[Int]] = []
    var coords: Set<Coordinate> = []

    for y in 0..<input.count*5 {
        var caveRow: [Int] = []
        for x in 0..<input[0].count*5 {
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

    let target = Coordinate(cave.count-1, cave.count-1)
    let result = dijkstra(graph: coords,
                          source: Coordinate(0, 0),
                          target: target,
                          getNeighbours: { $0.getAxialAdjacents(in: cave) },
                          getDistanceBetween: { cave[$1.y][$1.x] })

    print(result.distances[target]!)
}

try main()
