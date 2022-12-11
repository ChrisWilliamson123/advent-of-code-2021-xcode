import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")

    let monkeys = input.map(buildMonkey)
    print(monkeys)

    // inspect, adj worry, (/3 rounded down), test, throw for all items monkey is currently holding
    let rounds = 10000
    for roundIndex in 0..<rounds {
        for monkey in monkeys {
            for _ in 0..<monkey.items.count {
                // inspect
                monkey.items[0] = monkey.worryOperation(monkey.items[0])
                monkey.itemsInspected += 1
                // adjust
//                monkey.items[0] = monkey.items[0] / 3
                let result = monkey.test(monkey.items[0])
                let toThrow = monkey.items.remove(at: 0)
                if result {
                    monkeys[monkey.trueTarget].items.append(toThrow)
                } else {
                    monkeys[monkey.falseTarget].items.append(toThrow)
                }
            }
        }
//        print("After round \(roundIndex+1)")
//        for m in monkeys {
//            print(m, m.itemsInspected)
//        }
    }

    print(monkeys.map({ $0.itemsInspected }).sorted().reversed()[0..<2].multiply())
}

class Monkey: CustomStringConvertible {
    var items: [Int]
    let worryOperation: ((Int) -> Int)
    let test: ((Int) -> Bool)
    let trueTarget: Int
    let falseTarget: Int
    var itemsInspected = 0

    var description: String { "\(items), \(trueTarget), \(falseTarget)" }

    init(items: [Int], operation: @escaping ((Int) -> Int), test: @escaping ((Int) -> Bool), trueTarget: Int, falseTarget: Int) {
        self.items = items
        self.worryOperation = operation
        self.test = test
        self.trueTarget = trueTarget
        self.falseTarget = falseTarget
    }
}

private func buildMonkey(_ input: String) -> Monkey {
    let lineSplit = input.components(separatedBy: "\n")
    let items = lineSplit[1].components(separatedBy: ": ")[1].components(separatedBy: ", ").compactMap(Int.init)
    let operationSplit = lineSplit[2].components(separatedBy: ": ")[1]
//    let operation: ((Int) -> Int) = { $0 % 96577 }
    let operation: ((Int) -> Int)
    if operationSplit.contains("+") {
        operation = { $0 + Int(operationSplit.components(separatedBy: " ").last!)! % 9699690 }
    } else {
        operation = { $0 * (Int(operationSplit.components(separatedBy: " ").last!) ?? $0) % 9699690 }
    }
    let test: ((Int) -> Bool) = { $0 % Int(lineSplit[3].components(separatedBy: " ").last!)! == 0 }
    let trueTarget = Int(lineSplit[4].components(separatedBy: " ").last!)!
    let falseTarget = Int(lineSplit[5].components(separatedBy: " ").last!)!

    return Monkey(items: items, operation: operation, test: test, trueTarget: trueTarget, falseTarget: falseTarget)
}

try main()
