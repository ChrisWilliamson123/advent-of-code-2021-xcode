import Foundation

enum Instruction {
    case add(Int)
    case noop

    static func initialise(from string: String) -> Instruction {
        if string == "noop" { return .noop }
        return .add(Int(string.components(separatedBy: " ")[1])!)
    }
}

class CPU {
    private var cycleCount = 0 {
        didSet { handleCycleIteration() }
    }
    private var registerX = 1
    private var signalStrength: Int { cycleCount * registerX }
    private var signalStrengthsPerCycle: [Int: Int] = [:]
    private let screen = CRTScreen()

    func processInstructions(_ instructions: [Instruction]) {
        instructions.forEach({ instruction in
            switch instruction {
            case .noop:
                cycleCount += 1
            case .add(let amount):
                cycleCount += 1
                cycleCount += 1
                registerX += amount
            }
        })
    }

    func getTotalSignalStrength(for cycles: [Int]) -> Int {
        cycles.compactMap({ signalStrengthsPerCycle[$0] }).sum()
    }

    func printScreen() {
        screen.printScreen()
    }

    private func handleCycleIteration() {
        signalStrengthsPerCycle[cycleCount] = signalStrength

        let crtPos = screen.getPixelPosition(for: cycleCount)
        let spriteSpan = [registerX-1, registerX, registerX+1]
        if spriteSpan.contains(crtPos.x) {
            screen.drawPixel(at: crtPos)
        }
    }
}

class CRTScreen {
    private var pixels: [[Character]] = Array.init(repeating: Array.init(repeating: ".", count: 40), count: 6)

    func getPixelPosition(for cycleCount: Int) -> Coordinate {
        Coordinate((cycleCount - 1) % 40, (cycleCount-1) / 40)
    }

    func drawPixel(at position: Coordinate) {
        pixels[position.y][position.x] = "#"
    }

    func printScreen() {
        pixels.forEach { print($0.map(String.init).joined(separator: "")) }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let instructions = input.map(Instruction.initialise)

    let cpu = CPU()
    cpu.processInstructions(instructions)
    print(cpu.getTotalSignalStrength(for: [20, 60, 100, 140, 180, 220]))
    cpu.printScreen()
}

try main()
