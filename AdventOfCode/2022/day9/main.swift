import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let moves = input.map { i in i.split(separator: " ").map { String($0) } }

    let adjustment = [
        "U": Coordinate(0, -1),
        "D": Coordinate(0, 1),
        "L": Coordinate(-1, 0),
        "R": Coordinate(1, 0),
    ]

    let rope = Rope()

    moves.forEach({ rope.performMove(adjustment: adjustment[$0[0]]!, amount: Int($0[1])!) })

    print(rope.getVisitedCoordinatesCount(for: 1))
    print(rope.getVisitedCoordinatesCount(for: 9))
}

class Rope {
    private var knotPositions = Array.init(repeating: Coordinate(0, 0), count: 10)
    private var visitedCoordinates: [Int: Set<Coordinate>] = (1...9).reduce(into: [:], { $0[$1] = [Coordinate(0, 0)] })

    func performMove(adjustment: Coordinate, amount: Int) {
        for _ in 0..<amount {
            knotPositions[0] += adjustment
            moveKnots()
        }
    }

    func getVisitedCoordinatesCount(for knotIndex: Int) -> Int {
        visitedCoordinates[knotIndex]!.count
    }

    private func moveKnots() {
        for knotIndex in 1..<knotPositions.count where shouldMoveKnot(index: knotIndex) {
            moveKnot(at: knotIndex)
        }
    }

    private func shouldMoveKnot(index: Int) -> Bool {
        let previousKnotPositions = knotPositions[index-1]
        return !previousKnotPositions.adjacents.contains(knotPositions[index])
    }

    private func moveKnot(at index: Int) {
        let prev = knotPositions[index-1]
        let curr = knotPositions[index]
        let diff = Coordinate(prev.x - curr.x, prev.y - curr.y)
        let normalised = diff.normalised
        knotPositions[index] += normalised
        visitedCoordinates[index]?.insert(knotPositions[index])
    }
}

try main()
