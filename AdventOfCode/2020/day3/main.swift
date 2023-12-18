import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)
    let forest = Forest(input)

    let slopesToCheck: [Coordinate] = [
        .init(3, 1),
        .init(1, 1),
        .init(5, 1),
        .init(7, 1),
        .init(1, 2)
    ]

    let partOne = calculateNumberOfTreesHit(through: forest, usingSlope: slopesToCheck[0])
    print("Part 1: \(partOne)")

    let partTwo = slopesToCheck.map({ calculateNumberOfTreesHit(through: forest, usingSlope: $0) }).multiply()
    print("Part 2: \(partTwo)")
}

private func calculateNumberOfTreesHit(through forest: Forest, usingSlope slope: Coordinate) -> Int {
    var tobogganPosition = Coordinate(0, 0)
    var treesHit = 0
    while tobogganPosition.y < forest.maxY {
        tobogganPosition = Coordinate(tobogganPosition.x + slope.x, tobogganPosition.y + slope.y)
        if forest.doesTreeExist(at: tobogganPosition) {
            treesHit += 1
        }
    }
    return treesHit
}

struct Forest {
    private let trees: Set<Coordinate>
    let maxY: Int
    private let maxX: Int

    init(_ forestMap: [String]) {
        var trees = Set<Coordinate>()

        let maxY = forestMap.count - 1
        let maxX = forestMap[0].count - 1
        for y in (0...maxY) {
            for x in (0...maxX) where forestMap[y][x] == "#" {
                trees.insert(Coordinate(x, y))
            }

        }
        self.trees = trees
        self.maxY = maxY
        self.maxX = maxX
    }

    func doesTreeExist(at coordinate: Coordinate) -> Bool {
        let x = coordinate.x % (maxX + 1)
        return trees.contains(Coordinate(x, coordinate.y))
    }
}

Timer.time(main)
