import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var outputs: [Int] = Array(repeating: -1, count: 21)
    var bots: [Int: Set<Int>] = [:]
    var instructions = [Instruction]()

    for i in input {
        let split = i.split(separator: " ")
        if split.count == 6 {
            bots[Int(split[5])!, default: []].formUnion([Int(split[1])!])
        } else {
            instructions.append(.init(botID: Int(split[1])!,
                                      low: split[5] == "bot" ? .bot(Int(split[6])!) : .output(Int(split[6])!),
                                      high: split[10] == "bot" ? .bot(Int(split[11])!) : .output(Int(split[11])!)))
        }
    }

    while instructions.count > 0 {
        // Get the next bot which has two chips
        let bot = bots.first(where: { $0.value.count == 2 })!
        // Get the instruction for that bot
        let instructionIndex = instructions.firstIndex(where: { $0.botID == bot.key })!
        let instruction = instructions.remove(at: instructionIndex)

        let lowChip = bot.value.min()!
        let hiChip = bot.value.max()!

        if lowChip == 17 && hiChip == 61 {
            print("Part one:", bot.key)
        }

        let performInstruction: (Instruction, (low: Int, hi: Int)) -> Void = { inst, values in
            bots[bot.key]?.remove(values.low)
            switch inst.low {
            case .output(let outputBin): outputs[outputBin] = values.low
            case .bot(let botID): bots[botID, default: []].formUnion([values.low])
            }
            bots[bot.key]?.remove(values.hi)
            switch inst.high {
            case .output(let outputBin): outputs[outputBin] = values.hi
            case .bot(let botID): bots[botID, default: []].formUnion([values.hi])
            }
        }

        performInstruction(instruction, (lowChip, hiChip))
    }

    print("Part two:", outputs[0] * outputs[1] * outputs[2])
}

struct Instruction {
    let botID: Int
    let low: Destination
    let high: Destination

    enum Destination {
        case output(Int)
        case bot(Int)
    }
}

try main()
