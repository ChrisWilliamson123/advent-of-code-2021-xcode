import Foundation

enum Shout {
    case number(value: Double)
    indirect case operation(lhs: String, rhs: String, sign: String)

    func getDependencyValue(using graph: [String: Shout]) -> Double {
        switch self {
        case .number(let value):
            return (value)
        case .operation(let lhs, let rhs, let sign):
            let lhsDep = graph[lhs]!.getDependencyValue(using: graph)
            let rhsDep = graph[rhs]!.getDependencyValue(using: graph)
            switch sign {
            case "+": return lhsDep + rhsDep
            case "*": return lhsDep * rhsDep
            case "-": return lhsDep - rhsDep
            case "/": return lhsDep / rhsDep
            case "=":
                // Going to return the difference between the rhs and lhs and use that to check equality
                return rhsDep - lhsDep
            default: assert(false)
            }
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var instructions = input.reduce(into: [String: Shout](), { (partialResult, instruction) in
        let split = instruction.components(separatedBy: " ")
        let name = split[0][0..<4]
        if split.count == 2 {
            partialResult[name] = Shout.number(value: Double(split[1])!)
        } else {
            partialResult[name] = Shout.operation(lhs: split[1], rhs: split[3], sign: split[2])
        }
    })
    print(Int(instructions["root"]!.getDependencyValue(using: instructions)))

    // Replace root entry with an equals operator
    if case let .operation(lhs, rhs, _) = instructions["root"]! {
        instructions["root"] = .operation(lhs: lhs, rhs: rhs, sign: "=")
    }

    var lowerBound = 0
    var upperBound = Int.max
    var x: Int { lowerBound + ((upperBound - lowerBound) / 2) }
    var found = false
    while !found {
        instructions["humn"] = .number(value: Double(x))
        let result = instructions["root"]!.getDependencyValue(using: instructions)
        if result == 0 {
            found = true
            break
        } else {
            // Need to change this to < to get the example to pass
            if result > 0 {
                upperBound = x
            } else {
                lowerBound = x
            }
        }
    }
    print(lowerBound + ((upperBound - lowerBound) / 2))
}

Timer.time(main)
