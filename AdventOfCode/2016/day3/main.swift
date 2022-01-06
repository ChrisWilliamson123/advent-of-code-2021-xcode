import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let partOneTriangles = input.map({ Triangle(sides: matches(for: "(\\d+)", in: $0).map({ Int($0)! })) })
    print("Part one:", partOneTriangles.reduce(0, { $1.isValid ? $0 + 1 : $0 }))

    let allNumbers = input.map({ matches(for: "(\\d+)", in: $0).map({ Int($0)! }) }).flatMap({ $0 })
    var partTwoTriangles = [Triangle]()
    for i in stride(from: 8, to: allNumbers.count, by: 9) {
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-8], allNumbers[i-5], allNumbers[i-2] ]))
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-7], allNumbers[i-4], allNumbers[i-1] ]))
        partTwoTriangles.append(Triangle(sides: [ allNumbers[i-6], allNumbers[i-3], allNumbers[i-0] ]))
    }
    print("Part one:", partTwoTriangles.reduce(0, { $1.isValid ? $0 + 1 : $0 }))
}

struct Triangle {
    let sides: [Int]

    var isValid: Bool {
        let combinations = [(0, 1, 2), (0, 2, 1), (1, 2, 0)]

        for c in combinations {
            if !(sides[c.0] + sides[c.1] > sides[c.2]) {
                return false
            }
        }

        return true
    }
}

private func matches(for regex: String, in text: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

try main()
