import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    let insertionRules: [String: Character] = input[2..<input.count].reduce(into: [:], {
        let split = $1.components(separatedBy: " -> ")
        $0[split[0]] = split[1][0]
    })

    let pairs = (0..<input[0].count-1).map({ input[0][$0] + input[0][$0+1] })

    print("Part 1:", getExpansionResult(for: pairs, ticks: 10, insertionRules: insertionRules))
    print("Part 2:", getExpansionResult(for: pairs, ticks: 40, insertionRules: insertionRules))
}

private func getExpansionResult(for inputPairs: [String], ticks: Int, insertionRules: [String: Character]) -> Int {
    var pairCounts: [String: Int] = inputPairs.counts
    for _ in 0..<ticks {
        var newCounts: [String: Int] = [:]
        for (pair, currentPairCount) in pairCounts {
            guard let insertion = insertionRules[pair] else {
                newCounts[pair] = newCounts[pair, default: 0] + 1
                continue
            }

            let firstNewPair = pair[0] + String(insertion)
            let secondNewPair = String(insertion) + pair[1]

            newCounts[firstNewPair] = newCounts[firstNewPair, default: 0] + currentPairCount
            newCounts[secondNewPair] = newCounts[secondNewPair, default: 0] + currentPairCount
        }
        pairCounts = newCounts
    }
    var finalCounts: [Character: Int] = pairCounts.reduce(into: [:], { $0[$1.0[1]] = $0[$1.0[1], default: 0] + $1.1 })
    finalCounts[inputPairs[0][0]]! += 1

    let mostCommon = finalCounts.values.max()!
    let leastCommon = finalCounts.values.min()!
    return mostCommon - leastCommon
}

Timer.time(main)
