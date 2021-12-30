import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let instructions = buildInstructions(from: input)

    let grid = LightGrid()
    instructions.forEach({ grid.executeInstruction($0) })
    print("Part one:", grid.lightsOnCount)

    let brightnessGrid = BrightnessLightGrid()
    instructions.forEach({ brightnessGrid.executeInstruction($0) })
    print("Part two:", brightnessGrid.totalBrightness)

}

private func buildInstructions(from input: [String]) -> [LightGrid.Instruction] {
    input.map({ instructionText in
        let regex = Regex("((?:turn \\w+)|toggle) (\\d+),(\\d+) through (\\d+),(\\d+)")
        let matches = regex.getMatches(in: instructionText)
        let action: LightGrid.Instruction.Action
        switch matches[0] {
        case "toggle": action = .toggle
        case "turn off": action = .turnOff
        default: action = .turnOn
        }
        return .init(action: action, p1: Coordinate(Int(matches[1])!, Int(matches[2])!), p2: Coordinate(Int(matches[3])!,Int(matches[4])!))
    })
}

class BrightnessLightGrid: LightGrid {
    private var lightsWithBrightness: [Coordinate: Int] = [:]

    var totalBrightness: Int { lightsWithBrightness.values.reduce(0, +) }

    override func executeTurnOn(points: Set<Coordinate>) {
        points.forEach({ lightsWithBrightness[$0] = lightsWithBrightness[$0, default: 0] + 1 })
    }

    override func executeTurnOff(points: Set<Coordinate>) {
        points.forEach({ lightsWithBrightness[$0] = max(lightsWithBrightness[$0, default: 0], 1) - 1 })
    }

    override func executeToggle(points: Set<Coordinate>) {
        points.forEach({ lightsWithBrightness[$0] = lightsWithBrightness[$0, default: 0] + 2 })
    }
}

class LightGrid {
    private var onLights: Set<Coordinate> = []

    var lightsOnCount: Int { onLights.count }

    func executeInstruction(_ instruction: Instruction) {
        switch instruction.action {
        case .turnOn: executeTurnOn(points: instruction.allPoints)
        case .turnOff: executeTurnOff(points: instruction.allPoints)
        case .toggle: executeToggle(points: instruction.allPoints)
        }
    }

    func executeTurnOn(points: Set<Coordinate>) {
        onLights = onLights.union(points)
    }

    func executeTurnOff(points: Set<Coordinate>) {
        onLights = onLights.subtracting(points)
    }

    func executeToggle(points: Set<Coordinate>) {
        let lightsToTurnOff = onLights.intersection(points)
        let lightsToTurnOn = points.subtracting(onLights)
        onLights = onLights.subtracting(lightsToTurnOff).union(lightsToTurnOn)
    }

    struct Instruction {
        let action: Action
        let p1: Coordinate
        let p2: Coordinate

        var allPoints: Set<Coordinate> {
            assert(p2.x >= p1.x && p2.y >= p1.y, "Second coordinate does not have a larger x and y than first coordinate")
            var points: Set<Coordinate> = []
            for y in p1.y...p2.y {
                for x in p1.x...p2.x {
                    points.insert(Coordinate(x, y))
                }
            }
            return points
        }

        enum Action {
            case toggle
            case turnOn
            case turnOff
        }
    }
}

try main()
