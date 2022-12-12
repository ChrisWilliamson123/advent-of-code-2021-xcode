import Foundation

let partTwoCoords = [
    Coordinate(2, 0): "1",
    Coordinate(1, 1): "2",
    Coordinate(2, 1): "3",
    Coordinate(3, 1): "4",
    Coordinate(0, 2): "5",
    Coordinate(1, 2): "6",
    Coordinate(2, 2): "7",
    Coordinate(3, 2): "8",
    Coordinate(4, 2): "9",
    Coordinate(1, 3): "A",
    Coordinate(2, 3): "B",
    Coordinate(3, 3): "C",
    Coordinate(2, 4): "D",
]

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var code = ""
    let DIRECTIONS: [Character: (Int, Int)] = [
        "U": (0, -1),
        "R": (1, 0),
        "D": (0, 1),
        "L": (-1, 0),
    ]
    var position = (1, 1)

    for l in input {
        for d in l {
            let direction = DIRECTIONS[d]!
            let nextPos = (position.0 + direction.0, position.1 + direction.1)
            if isValidPosition(nextPos) {
                position = nextPos
            }
        }
        code += getDigit(for: position)
    }

    print("Part one:", code)

    var partTwoPos = Coordinate(0, 2)
    code = ""
    for l in input {
        for d in l {
            let direction = DIRECTIONS[d]!
            let nextPos = Coordinate(partTwoPos.x + direction.0, partTwoPos.y + direction.1)
            if partTwoCoords.keys.contains(nextPos) {
                partTwoPos = nextPos
            }
        }
        code += partTwoCoords[partTwoPos]!
    }

    print("Part two:", code)
}

private func isValidPosition(_ position: (Int, Int)) -> Bool {
    (position.0 >= 0 && position.0 <= 3) && (position.1 >= 0 && position.1 < 3)
}

private func getDigit(for position: (Int, Int)) -> String {
    "\((position.1 * 3) + position.0 + 1)"
}

Timer.time(main)
