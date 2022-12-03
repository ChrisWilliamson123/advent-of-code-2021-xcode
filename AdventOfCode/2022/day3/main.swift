import Foundation

func main() throws {
    let rucksacks: [String] = try readInput(fromTestFile: false)
    let part1 = rucksacks.reduce(0) { $0 + getDuplicateValue(in: $1) }
    print(part1)

    let part2 = stride(from: 0, to: rucksacks.count-1, by: 3).reduce(0, { $0 + getCommonValue(in: [ rucksacks[$1], rucksacks[$1+1], rucksacks[$1+2] ]) })
    print(part2)
}

func getDuplicateValue(in rucksack: String) -> Int {
    let asciiValues = rucksack.map { String($0).asciiNormalised }
    let firstHalf = asciiValues[0..<asciiValues.count/2]
    let secondHalf = asciiValues[asciiValues.count/2..<asciiValues.count]
    return firstHalf.first(where: { secondHalf.contains($0) })!
}

func getCommonValue(in rucksacks: [String]) -> Int {
    String(rucksacks[0].first(where: { rucksacks[1].contains($0) && rucksacks[2].contains($0) })!).asciiNormalised
}

try main()
