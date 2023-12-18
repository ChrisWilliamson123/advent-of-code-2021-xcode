import Foundation

struct DigInstruction {
    let direction: String
    let distance: Int

    var directionCoordinate: Coordinate {
        switch direction {
        case "R": return Coordinate(1, 0)
        case "L": return Coordinate(-1, 0)
        case "U": return Coordinate(0, -1)
        case "D": return Coordinate(0, 1)
        default: assert(false, "Invalid direction found")
        }
    }
}

final class Lagoon {
    var diggerPosition: Coordinate = Coordinate(0, 0)
    let instructions: [DigInstruction]
    var vertexes: [Coordinate] = [.zero]

    var perimeterArea: Int {
        (1..<vertexes.count).reduce(0, { $0 + vertexes[$1].getManhattanDistance(to: vertexes[$1-1]) })
    }

    var numberOfInternalCoordinates: Int {
        // What we need is the number of internal coordinates which is different to the internal area
        // Can get the internal area by using the shoelace formula
        let vertexes = vertexes
        var lhs: [Int] = []
        var rhs: [Int] = []

        for i in 1..<vertexes.count {
            lhs.append(vertexes[i-1].x * vertexes[i].y)
            rhs.append(vertexes[i-1].y * vertexes[i].x)
        }
        lhs.append(vertexes[vertexes.count - 1].x * vertexes[0].y)
        rhs.append(vertexes[vertexes.count - 1].y * vertexes[0].x)

        let summed = zip(lhs, rhs).reduce(0, { $0 + ($1.0 - $1.1) })
        let area = summed / 2
        // Then we can sub the calculated area into Pick's theorem to get the number of internal coordinates
        return area - ((perimeterArea / 2) - 1)
    }

    init(instructions: [DigInstruction]) {
        self.instructions = instructions
    }

    func followInstructions() {
        instructions.forEach({
            let destination = diggerPosition + ($0.directionCoordinate * $0.distance)
            vertexes.append(destination)
            diggerPosition = destination
        })
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let instructions: [DigInstruction] = input.map({
        let split = $0.split(separator: " ")
        return DigInstruction(direction: String(split[0]), distance: Int(String(split[1]))!)
    })

    let p1Lagoon = Lagoon(instructions: instructions)
    p1Lagoon.followInstructions()

    print(p1Lagoon.perimeterArea + p1Lagoon.numberOfInternalCoordinates)

    let swappedInstructions = input.map({
        let split = $0.split(separator: " ")
        let hexCode = String(split[2])[2..<split[2].count-1]
        let distance = Int(hexCode[0..<hexCode.count-1], radix: 16)!
        switch hexCode[hexCode.length - 1] as Character {
        case "0": return DigInstruction(direction: "R", distance: distance)
        case "1": return DigInstruction(direction: "D", distance: distance)
        case "2": return DigInstruction(direction: "L", distance: distance)
        case "3": return DigInstruction(direction: "U", distance: distance)
        default: assert(false, "Invalid direction string")
        }
    })

    let p2Lagoon = Lagoon(instructions: swappedInstructions)
    p2Lagoon.followInstructions()

    print(p2Lagoon.perimeterArea + p2Lagoon.numberOfInternalCoordinates)
}

Timer.time(main)
