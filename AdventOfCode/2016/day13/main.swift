import Foundation

func main() throws {
    let input = 1350

    let start = Coordinate(1, 1)

    func bfs(start: Coordinate, destination: Coordinate, stopAt: Int? = nil) -> Int {
        var frontier: [(pos: Coordinate, distance: Int)] = [(start, 0)]
        var explored: Set<Coordinate> = [start]
        while !frontier.isEmpty {
            let (currentPos, distance) = frontier.popLast()!
            if currentPos == destination { return distance }

            let axialAdjacents = currentPos.getAxialAdjacents().filter({ $0.x >= 0 && $0.y >= 0 })

            for a in axialAdjacents where !explored.contains(a) && isOpenSpace(a, input: input) {
                if distance == stopAt { return explored.count }
                frontier.insert((a, distance + 1), at: 0)
                explored.insert(a)
            }
        }
        assert(false)
    }

    print(bfs(start: start, destination: Coordinate(31, 39)))
    print(bfs(start: start, destination: Coordinate(1000, 1000), stopAt: 50))
}

private func isOpenSpace(_ coord: Coordinate, input: Int) -> Bool {
    let binaryRepresentation = String(((coord.x * coord.x) + (3*coord.x) + (2 * coord.x * coord.y) + coord.y + (coord.y * coord.y) + input), radix: 2)
    return binaryRepresentation.filter({ $0 == "1" }).count % 2 == 0
}

Timer.time(main)
