import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var people: [String: [(neighbour: String, happinessChange: Int)]] = [:]

    for i in input {
        let regex = Regex("(\\w+) would (\\w+) (\\d+) happiness units by sitting next to (\\w+).")
        let matches = regex.getMatches(in: i)
        let value = Int((matches[1] == "gain" ? "" : "-") + matches[2])!
        people[matches[0]] = people[matches[0], default: []] + [(matches[3], value)]
    }

    let peopleNames: [String] = Array(people.keys)
    for p in peopleNames {
        people["me"] = people["me", default: []] + [(p, 0)]
        people[p] = people[p, default: []] + [("me", 0)]
    }

    let seatingCombinations: [[String]] = Array(people.keys).combinations(count: people.keys.count)

    var maxChange = Int.min
    for sc in seatingCombinations {
        var change = 0
        for personIndex in 0..<sc.count {
            let leftIndex = personIndex - 1 < 0 ? seatingCombinations[0].count - 1 : personIndex - 1
            let rightIndex = personIndex + 1 > seatingCombinations[0].count - 1 ? 0 : personIndex + 1

            change += people[sc[personIndex]]!.first(where: { $0.0 == sc[leftIndex] })!.1
            change += people[sc[personIndex]]!.first(where: { $0.0 == sc[rightIndex] })!.1
        }
        maxChange = max(maxChange, change)
    }

    print("Part one:", maxChange)
}

Timer.time(main)
