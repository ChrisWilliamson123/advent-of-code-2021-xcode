import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let moves = input.map { i in i.split(separator: " ").map { String($0) } }

    var ropePositions: [Coordinate] = Array.init(repeating: Coordinate(0,0), count: 10)
    let adjustment = [
        "U": Coordinate(0, -1),
        "D": Coordinate(0, 1),
        "L": Coordinate(-1, 0),
        "R": Coordinate(1, 0),
    ]
    var visited: [Int: Set<Coordinate>] = (1...9).reduce(into: [:], { $0[$1] = [Coordinate(0, 0)] })

    for m in moves {
        let adjustment = adjustment[m[0]]!
        for _ in 0..<Int(m[1])! {
            ropePositions[0] = ropePositions[0] + adjustment

            for j in 1..<ropePositions.count {
                let adjacents = ropePositions[j-1].getAdjacentsIncludingSelf()
                if !adjacents.contains(ropePositions[j]) {
                    let prev = ropePositions[j-1]
                    let curr = ropePositions[j]
                    let diff = Coordinate(prev.x - curr.x, prev.y - curr.y)
                    let getNormalisedValue: ((Int) -> Int) = { $0 == 0 ? 0 : $0 / abs($0) }
                    let normalised = Coordinate(getNormalisedValue(diff.x), getNormalisedValue(diff.y))
                    ropePositions[j] = ropePositions[j] + normalised

                    visited[j]?.insert(ropePositions[j])
                }
            }
        }
    }

    print(visited[1]!.count)
    print(visited[9]!.count)
}

try main()
