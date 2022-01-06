import Foundation

func main() throws {
    let directionsText: String = try readInput(fromTestFile: false)[0]
    var directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    var position = (0, 0)
    var locations = Set<Coordinate>()
    var partTwoDone = false

    for d in directionsText.components(separatedBy: ", ") {
        let matches = Regex("(\\w)(\\d+)").getMatches(in: d)

        matches[0] == "R" ? directions.rotateLeft(positions: 1) : directions.rotateRight(positions: 1)

        let value = Int(matches[1])!
        for _ in 1...value {
            position.0 += directions[0].0 * 1
            position.1 += directions[0].1 * 1
            let coord = Coordinate(position.0, position.1)
            if !partTwoDone && locations.contains(coord) {
                print("Part two:", coord.getManhattanDistance(to: .init(0, 0)))
                partTwoDone = true
            }
            locations.insert(coord)
        }
    }
    print("Part one:", abs(position.0) + abs(position.1))
}

try main()
