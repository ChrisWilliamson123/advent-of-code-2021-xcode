import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let partOneTriangles = input.map({ Triangle(sides: Regex("(\\d+)").getGreedyMatches(in: $0).map({ Int($0)! })) })
    print("Part one:", partOneTriangles.reduce(0, { $1.isValid ? $0 + 1 : $0 }))

    let allNumbers = input.map({ Regex("(\\d+)").getGreedyMatches(in: $0).map({ Int($0)! }) }).flatMap({ $0 })
    var partTwoTriangles = [Triangle]()
    for i in stride(from: 8, to: allNumbers.count, by: 9) {
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-8], allNumbers[i-5], allNumbers[i-2] ]))
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-7], allNumbers[i-4], allNumbers[i-1] ]))
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-6], allNumbers[i-3], allNumbers[i-0] ]))
    }
    print("Part two:", partTwoTriangles.reduce(0, { $1.isValid ? $0 + 1 : $0 }))
}

struct Triangle {
    let sides: [Int]

    var isValid: Bool {
        let combinations = [(0, 1, 2), (0, 2, 1), (1, 2, 0)]

        for c in combinations where !(sides[c.0] + sides[c.1] > sides[c.2]) {
            return false
        }

        return true
    }
}

Timer.time(main)
