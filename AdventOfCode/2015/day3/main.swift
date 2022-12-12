import Foundation

func main() throws {
    let directionsString: String = try readInput(fromTestFile: false)[0]
    let directions = [Character](directionsString)
    var santa = Santa()

    for d in directions {
        santa.move(direction: d)
    }

    print("Part one:", santa.numberOfHousesDeliveredTo)

    santa = Santa()
    var roboSanta = Santa()

    for i in stride(from: 0, to: directions.count, by: 2) {
        let d1 = directions[i]
        let d2 = directions[i+1]

        santa.move(direction: d1)
        roboSanta.move(direction: d2)
    }

    print("Part two:", santa.locationsVisited.merging(roboSanta.locationsVisited, uniquingKeysWith: +).count)
}

struct Santa {
    private var currentPosition = Coordinate(0, 0)
    var locationsVisited: [Coordinate: Int] = [Coordinate(0, 0): 1]

    var numberOfHousesDeliveredTo: Int { locationsVisited.count }

    mutating func move(direction: Character) {
        switch direction {
        case "^": currentPosition = currentPosition + Coordinate(0, 1)
        case ">": currentPosition = currentPosition + Coordinate(1, 0)
        case "v": currentPosition = currentPosition + Coordinate(0, -1)
        case "<": currentPosition = currentPosition + Coordinate(-1, 0)
        default: assert(false)
        }
        locationsVisited[currentPosition] = (locationsVisited[currentPosition] ?? 0) + 1
    }
}

Timer.time(main)
