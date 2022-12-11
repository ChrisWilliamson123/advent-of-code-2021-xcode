import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    var monkeys = input.map(buildMonkey)
    let lcm = monkeys.map({ $0.divisor }).multiply()

    let partOneGame = Game(rounds: 20, makeAdjustment: true, lcm: nil, monkeys: monkeys)
    partOneGame.run()
    print(partOneGame.monkeyBusiness)

    monkeys = input.map(buildMonkey)
    let partTwoGame = Game(rounds: 10000, makeAdjustment: false, lcm: lcm, monkeys: monkeys)
    partTwoGame.run()
    print(partTwoGame.monkeyBusiness)
}

struct Game {
    let rounds: Int
    let makeAdjustment: Bool
    let lcm: Int?
    let monkeys: [Monkey]
    var monkeyBusiness: Int {
        monkeys.map({ $0.itemsInspected }).sorted().reversed()[0..<2].multiply()
    }

    func run() {
        for _ in 0..<rounds {
            for monkey in monkeys {
                for _ in 0..<monkey.items.count {
                    // inspect
                    monkey.items[0] = monkey.worryOperation(monkey.items[0])
                    if let lcm = lcm {
                        monkey.items[0] %= lcm
                    }
                    monkey.itemsInspected += 1
                    // adjust
                    if makeAdjustment {
                        monkey.items[0] = monkey.items[0] / 3
                    }
                    // throw
                    let result = monkey.test(monkey.items[0])
                    let toThrow = monkey.items.remove(at: 0)
                    let target = result ? monkey.trueTarget : monkey.falseTarget
                    monkeys[target].items.append(toThrow)
                }
            }
        }
    }
}

class Monkey: CustomStringConvertible {
    var items: [Int]
    let worryOperation: ((Int) -> Int)
    let test: ((Int) -> Bool)
    let trueTarget: Int
    let falseTarget: Int
    let divisor: Int
    var itemsInspected = 0

    var description: String { "\(items), \(trueTarget), \(falseTarget)" }

    init(items: [Int], operation: @escaping ((Int) -> Int), test: @escaping ((Int) -> Bool), trueTarget: Int, falseTarget: Int, divisor: Int) {
        self.items = items
        self.worryOperation = operation
        self.test = test
        self.trueTarget = trueTarget
        self.falseTarget = falseTarget
        self.divisor = divisor
    }
}

private func buildMonkey(_ input: String) -> Monkey {
    let lineSplit = input.components(separatedBy: "\n")
    let items = lineSplit[1].components(separatedBy: ": ")[1].components(separatedBy: ", ").compactMap(Int.init)
    let operationSplit = lineSplit[2].components(separatedBy: ": ")[1]
    let operation: ((Int) -> Int)
    if operationSplit.contains("+") {
        operation = { $0 + Int(operationSplit.components(separatedBy: " ").last!)! }
    } else {
        operation = { $0 * (Int(operationSplit.components(separatedBy: " ").last!) ?? $0) }
    }
    let divisor = Int(lineSplit[3].components(separatedBy: " ").last!)!
    let test: ((Int) -> Bool) = { $0 % divisor == 0 }
    let trueTarget = Int(lineSplit[4].components(separatedBy: " ").last!)!
    let falseTarget = Int(lineSplit[5].components(separatedBy: " ").last!)!

    return Monkey(items: items, operation: operation, test: test, trueTarget: trueTarget, falseTarget: falseTarget, divisor: divisor)
}

try main()
