import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var instructions = Set(buildInstructions(from: input))
    let literals = instructions.filter({
        if case .literal(_) = $0.op {
            return true
        }
        return false
    })

    var circuit = Circuit()
    for l in literals { circuit.executeInstruction(l); instructions.remove(l) }

    while !instructions.isEmpty {
        let nextInstruction = instructions.first(where: { $0.op.inputGates.isSubset(of: circuit.wires.keys) })!
        circuit.executeInstruction(nextInstruction)
        instructions.remove(nextInstruction)
    }

    print(circuit.wires["a"] ?? "N/A")
}

struct Circuit {
    var wires: [String: UInt16] = [:]

    mutating func executeInstructions(_ instructions: [Instruction]) {
        instructions.forEach({ executeInstruction($0) })
    }

    mutating func executeInstruction(_ instruction: Instruction) {
        switch instruction.op {
        case .literal(let literal): wires[instruction.output] = literal
        case .not(let input): wires[instruction.output] = ~wires[input]!
        case .and(let a, let b):
            if let lhsAsInt = UInt16(a) {
                wires[instruction.output] = lhsAsInt & wires[b]!
            } else {
                wires[instruction.output] = wires[a]! & wires[b]!
            }
        case .or(let a, let b): wires[instruction.output] = wires[a]! | wires[b]!
        case .lshift(let input, let shiftAmount): wires[instruction.output] = wires[input]! << shiftAmount
        case .rshift(let input, let shiftAmount): wires[instruction.output] = wires[input]! >> shiftAmount
        case .wire(let input): wires[instruction.output] = wires[input]!
        }
    }
}

private func buildInstructions(from input: [String]) -> [Instruction] {
    input.map({ inputText in
        let ioSplit = inputText.components(separatedBy: " -> ")
        let output: String = ioSplit[1]
        if let asInt = UInt16(ioSplit[0]) {
            return .init(output: output, op: .literal(asInt))
        }
        let inputSplit = ioSplit[0].split(separator: " ")
        if inputSplit.count == 1 {
            return .init(output: output, op: .wire(String(inputSplit[0])))
        }
        if inputSplit.count == 2 {
            return .init(output: output, op: .not(String(inputSplit[1])))
        }
        switch inputSplit[1] {
        case "AND": return .init(output: output, op: .and(String(inputSplit[0]), String(inputSplit[2])))
        case "OR": return .init(output: output, op: .or(String(inputSplit[0]), String(inputSplit[2])))
        case "LSHIFT": return .init(output: output, op: .lshift(String(inputSplit[0]), UInt16(inputSplit[2])!))
        case "RSHIFT": return .init(output: output, op: .rshift(String(inputSplit[0]), UInt16(inputSplit[2])!))
        default: assert(false)
        }
    })
}

struct Instruction: Hashable {
    let output: String
    let op: Operator

    enum Operator: Hashable {
        static func == (lhs: Instruction.Operator, rhs: Instruction.Operator) -> Bool {
            "\(lhs)" == "\(lhs)"
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self)")
        }

        case wire(String)
        case literal(UInt16)
        case not(String)
        case and(String, String)
        case or(String, String)
        case lshift(String, UInt16)
        case rshift(String, UInt16)

        var inputGates: Set<String> {
            switch self {
            case .wire(let input): return [input]
            case .literal(_):
                return []
            case .not(let input):
                return [input]
            case .and(let a, let b):
                return Set([a, b].compactMap({
                    if UInt16($0) != nil {
                        return nil
                    }
                    return $0
                }))
            case .or(let a, let b):
                return [a, b]
            case .lshift(let a, _):
                return [a]
            case .rshift(let a, _):
                return [a]
            }
        }
    }
}

try main()
