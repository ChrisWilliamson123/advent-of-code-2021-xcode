import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var counts: [[Character: Int]] = Array(repeating: [:], count: input[0].count)
    for l in input { for i in 0..<l.count { counts[i][l[i], default: 0] += 1 } }

    print("Part one:", String(counts.map({ $0.max(by: { $0.value < $1.value })!.key })))
    print("Part two:", String(counts.map({ $0.min(by: { $0.value < $1.value })!.key })))
}

try main()
