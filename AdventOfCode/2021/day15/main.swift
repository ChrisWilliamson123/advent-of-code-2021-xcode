import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let partOne = buildCave(from: input)
    let partOneResult = dijkstra(graph: partOne.coords,
                          source: Coordinate(0, 0),
                          target: Coordinate(partOne.cave.count-1, partOne.cave.count-1),
                          getNeighbours: { $0.getAxialAdjacents(in: partOne.cave) },
                          getDistanceBetween: { partOne.cave[$1.y][$1.x] })

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

func aStar(graph: [[Int]], source: Coordinate, end: Coordinate) -> Int {
    var prev: [Coordinate: Coordinate?] = [:]
    var dist: [Coordinate: Int] = [:]

    for y in 0..<graph.count {
        for x in 0..<graph[0].count {
            let coord = Coordinate(x, y)
            if coord != source {
                dist[coord] = Int.max
                prev[coord] = nil
            }
        }
    }

    dist[source] = 0

    var fScore: [Coordinate: Double] = [:]
    fScore[source] = euclidianDistance(source: source, end: end)
    var queue = Heap(elements: [], priorityFunction: { fScore[$0]! < fScore[$1]! })
    queue.enqueue(source)

    while !queue.isEmpty {
        let current = queue.dequeue()!
        if current == end { return dist[current]! }

        for n in current.getAxialAdjacents(in: graph) {
            let tentativeGScore = dist[current]! + graph[n.y][n.x]
            if tentativeGScore < dist[n]! {
                prev[n] = current
                dist[n] = tentativeGScore
                fScore[n] = Double(tentativeGScore) + euclidianDistance(source: n, end: end)

                if queue.indexMap[n] != nil {
                    queue.changeElement(n, to: n)
                } else {
                    queue.enqueue(n)
                }
            }
        }
    }

    return 0
}

func euclidianDistance(source: Coordinate, end: Coordinate) -> Double {
    let dx = end.x - source.x
    let dy = end.y - source.y
    return sqrt(Double((dx*dx) + (dy*dy)))
}

try main()
