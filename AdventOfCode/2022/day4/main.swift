import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let pairList = input.map {
        getRanges(from: $0.split(separator: ",").map { String($0) })
    }

    let part1 = pairList.reduce(0, {
        if $1[0].fullyContains($1[1]) || $1[1].fullyContains($1[0]) {
            return $0 + 1
        }
        return $0
    })
    print(part1)

    let part2 = pairList.reduce(0) {
        if $1[0].overlaps($1[1]) || $1[1].overlaps($1[0]) {
            return $0 + 1
        }
        return $0
    }
    print(part2)
}

extension ClosedRange<Int> {
    func fullyContains(_ otherRange: ClosedRange<Int>) -> Bool {
        return otherRange.lowerBound >= lowerBound && otherRange.upperBound <= upperBound
    }
}

private func getRanges(from pairs: [String]) -> [ClosedRange<Int>] {
    let splits = pairs.map {
        let split = $0.split(separator: "-")
        return split.map { Int($0)! }
    }
    let ranges = splits.map {
        $0[0]...$0[1]
    }
    return ranges
}

try main()
