import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var journeys: [String: [(String, Int)]] = [:]
    for i in input {
        let regex = Regex("(\\w+) to (\\w+) = (\\d+)")
        let groups = regex.getMatches(in: i)
        journeys[groups[0], default: []] += [(groups[1], Int(groups[2])!)]
        journeys[groups[1], default: []] += [(groups[0], Int(groups[2])!)]
    }

    let combinations = Set(Array(journeys.keys).combinations(count: journeys.keys.count))

    var minimum = Int.max
    var maximum = Int.min
    for c in combinations {
        var total = 0
        for i in 1..<c.count {
            total += journeys[c[i-1]]!.first(where: { $0.0 == c[i] })!.1
        }
        minimum = min(minimum, total)
        maximum = max(maximum, total)
    }

    print("Part one:", minimum)
    print("Part two:", maximum)
}

try main()
