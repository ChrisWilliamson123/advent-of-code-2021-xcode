import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)
    var cave: [[Int]] = []

    for y in 0..<input.count*5 {
        var caveRow: [Int] = []
        for x in 0..<input[0].count*5 {
            let properXIndex = x % input[0].count
            let xAdjustment = x / input[0].count
            let properYIndex = y % input.count
            let yAdjustment = y / input.count
            let adjustment = xAdjustment + yAdjustment
            // let adjustment = max(xAdjustment, yAdjustment)
            // let initialValue = Int(input[y][x])!
            // print(x, properXIndex, xAdjustment)
            var value = Int(input[properYIndex][properXIndex])!
            // print(value)
            if value + adjustment > 9 {
                value = (value + adjustment) % 9
            } else {
                value += adjustment
            }
            caveRow.append(value)
            // print(y, x, yAdjustment, xAdjustment, adjustment, value)
        }
        cave.append(caveRow)
    }
    // print(cave)
    // let cave: [[Int]] = input.map({ $0.map({ Int($0)! }) })
    // print(cave)

    // print(getLeastRiskyRoute(startingAt: Coordinate(0,0)))
    // let dijk = dijkstra(graph: cave, source: Coordinate(0, 0))
    // print(dijk.dist[Coordinate(cave[0].count-1, cave.count-1)]!)

    // for row in cave {
    //     print(row.map({String($0)}).joined())
    // }

    let aStarResult = aStar(graph: cave, source: Coordinate(0, 0), end: Coordinate(cave[0].count-1, cave.count-1))
    print(aStarResult)
}

func aStar(graph: [[Int]], source: Coordinate, end: Coordinate) -> Int {
    var openVertices: Set<Coordinate> = [source]
    var cameFrom: [Coordinate: Coordinate] = [:]
    var gScore: [Coordinate: Int] = [:]
    gScore[source] = 0

    var fScore: [Coordinate: Double] = [:]
    fScore[source] = euclidianDistance(source: source, end: end)

    while openVertices.count > 0 {
        var current = openVertices.min(by: { fScore[$0]! < fScore[$1]! })!
        print(openVertices.count, current)
        if current == end {
            return gScore[current]!
        }

        openVertices.remove(current)

        let neighbours = current.getAxialAdjacents(in: graph).filter({( $0.x >= 0 && $0.x < graph[0].count ) && ( $0.y >= 0 && $0.y < graph.count ) })
        for n in neighbours {
            var tentativeGScore = gScore[current]! + graph[n.y][n.x]
            if tentativeGScore < (gScore[n] ?? Int.max) {
                cameFrom[n] = current
                gScore[n] = tentativeGScore
                fScore[n] = Double(tentativeGScore) + euclidianDistance(source: n, end: end)
                if !openVertices.contains(n) {
                    openVertices.insert(n)
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
