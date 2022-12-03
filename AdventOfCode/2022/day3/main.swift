import Foundation
//import Collections

func main() throws {
    let rucksacks: [String] = try readInput(fromTestFile: false)

    var sum = 0
    for rucksack in rucksacks {
        let asciiValues = rucksack.map { String($0).asciiNormalised }
        let firstHalf = asciiValues[0..<asciiValues.count/2]
        let secondHalf = asciiValues[asciiValues.count/2..<asciiValues.count]
        let duplicate = firstHalf.first(where: { secondHalf.contains($0) })
        duplicate.map { sum += $0 }
    }
    print(sum)

    sum = 0

    for groupIndex in stride(from: 0, to: rucksacks.count-1, by: 3) {
        let rucksackGroups = [rucksacks[groupIndex], rucksacks[groupIndex+1], rucksacks[groupIndex+2]]
        let common = rucksackGroups[0].first(where: { rucksackGroups[1].contains($0) && rucksackGroups[2].contains($0) })
        common.map { sum += String($0).asciiNormalised }
    }

    print(sum)
}

extension StringProtocol {
    var asciiNormalised: Int {
        let ascii = asciiValue
        if self.first!.isUppercase {
            return ascii - 38
        }
        return ascii - 96
    }
}

try main()
