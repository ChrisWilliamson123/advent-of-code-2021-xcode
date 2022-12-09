import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let moves = input.map { i in i.split(separator: " ").map { String($0) } }
//    var headPosition = Coordinate(0, 0)
//    var tailPosition = Coordinate(0, 0)
    var ropePositions: [Coordinate] = Array.init(repeating: Coordinate(0,0), count: 10)
    let adjustment = [
        "U": Coordinate(0, -1),
        "D": Coordinate(0, 1),
        "L": Coordinate(-1, 0),
        "R": Coordinate(1, 0),
    ]
    var visited: Set<Coordinate> = [Coordinate(0,0)]
    for m in moves {
//        print(m)
        let adjustment = adjustment[m[0]]!
        for _ in 0..<Int(m[1])! {
//            var previousHeadPos = ropePositions[0]
            ropePositions[0] = ropePositions[0] + adjustment
//            print("Head has moved to ", ropePositions[0])
            for j in 1..<ropePositions.count {
                let adjacents = ropePositions[j-1].getAdjacentsIncludingSelf()
                if !adjacents.contains(ropePositions[j]) {
                    let prev = ropePositions[j-1]
                    let curr = ropePositions[j]
                    let diff = Coordinate(prev.x - curr.x, prev.y - curr.y)
                    let normalised = Coordinate(diff.x == 0 ? 0 :diff.x / abs(diff.x), diff.y == 0 ? 0 : diff.y / abs(diff.y))
                    ropePositions[j] = ropePositions[j] + normalised
//                    visited.insert(ropePositions[9])
//                    let newPrev = ropePositions[j]
//                    ropePositions[j] = previousHeadPos
////                    print("\(j) has moved to ", previousHeadPos)
                    if j == 9 {
//                        print(ropePositions[j])
                        visited.insert(ropePositions[j])
                    }
//                    previousHeadPos = newPrev
                }
            }
//            printRope(ropePositions)
        }
//        print("COMPLETE!")
//        print(ropePositions)
    }

    print(visited.count)
}

func printRope(_ rope: [Coordinate]) {
    for y in -20..<20 {
        var line = ""
        for x in -20..<20 {
            let coord = Coordinate(x, y)
            if let index = rope.firstIndex(of: coord) {
                line.append("\(index)")
            } else {
                line.append(".")
            }
        }
        print(line)
    }
    print("\n")
}

try main()
