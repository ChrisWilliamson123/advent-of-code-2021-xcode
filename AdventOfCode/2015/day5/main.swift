import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let strings: [NString] = input.map({ NString(content: [Character]($0)) })
    print("Part one:", strings.reduce(0, { $1.isNice ? $0 + 1 : $0 }))

    let partTwoStrings: [NString2] = input.map({ NString2(content: [Character]($0)) })
    print("Part two:", partTwoStrings.reduce(0, { $1.isNice ? $0 + 1 : $0 }))
}

struct NString {
    let content: [Character]

    var counts: [Character: Int]
    var vowelCount: Int {
        ["a", "e", "i", "o", "u"].map({ counts[$0] ?? 0 }).sum()
    }
    var containsDoubleLetter = false
    var containsInvalidString = false

    var isNice: Bool {
        vowelCount >= 3 && containsDoubleLetter && !containsInvalidString
    }

    init(content: [Character]) {
        self.content = content
        var counts: [Character: Int] = [:]

        for i in 0..<content.count {
            let char = content[i]
            if i > 0 {
                if content[i-1] == char {
                    self.containsDoubleLetter = true
                }

                if ["ab", "cd", "pq", "xy"].contains([String(content[i-1]), String(char)].joined()) {
                    self.containsInvalidString = true
                }
            }
            counts[char] = (counts[char] ?? 0) + 1
        }
        self.counts = counts
    }
}

struct NString2 {
    let pairs: [String]
    var containsRepeatWithCharBetween = false

    var containsRepeatedPair: Bool {
        var indexesOfPairs: [String: [Int]] = [:]
        for i in 0..<pairs.count {
            indexesOfPairs[pairs[i]] = (indexesOfPairs[pairs[i]] ?? []) + [i]
        }

        let validPairs = indexesOfPairs.filter({ $0.value.count > 1 && ($0.value.last! - $0.value.first!) > 1 })
        return validPairs.count > 0
    }
    var isNice: Bool { containsRepeatedPair && containsRepeatWithCharBetween }

    init(content: [Character]) {
        var pairs: [String] = []
        for i in 0..<content.count {
            let char = content[i]
            if i > 0 {
                pairs.append([String(content[i-1]), String(char)].joined())
            }

            if i > 1 && content[i-2] == char {
                self.containsRepeatWithCharBetween = true
            }
        }
        self.pairs = pairs
    }
}

try main()
