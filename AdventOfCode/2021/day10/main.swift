import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let chunks: [String] = try readInput(fromTestFile: isTestMode)

    let openers: Set<Character> = ["[", "(", "{", "<"]
    let closers: Set<Character> = ["]", ")", "}", ">"]

    var illegals: [Character] = []
    var closingsNeeded: [[Character]] = []

    for chunk in chunks {
        var stack = Stack<Character>()
        var isCorrupted = false

        for c in chunk {
            if openers.contains(c) {
                stack.push(c)
            }

            if closers.contains(c) {
                let expectedOpener = getOpener(for: c)
                if stack.peek() == expectedOpener {
                    _ = stack.pop()
                } else {
                    isCorrupted = true
                    illegals.append(c)
                    break
                }
            }
        }

        if stack.peek() != nil && !isCorrupted {
            closingsNeeded.append(stack.all.reversed().map({ getCloser(for: $0) }))
        }
    }

    print("Part 1:", illegals.reduce(0, { $0 + getPointsForIllegal($1) }))
    
    let incompleteChunkPoints: [Int] = closingsNeeded.map({ c in
        c.reduce(0, { ($0 * 5) + getPointsForCloser($1) })
    })

    print("Part 2:", incompleteChunkPoints.sorted()[incompleteChunkPoints.count / 2])
}

private func getCloser(for opener: Character) -> Character {
    [ "(": ")", "[": "]", "{": "}", "<": ">" ][opener]!
}

private func getOpener(for closer: Character) -> Character {
    [ ")": "(", "]": "[", "}": "{", ">": "<" ][closer]!
}

private func getPointsForIllegal(_ character: Character) -> Int {
    [ ")": 3, "]": 57, "}": 1197, ">": 25137 ][character]!
}

private func getPointsForCloser(_ character: Character) -> Int {
    [ ")": 1, "]": 2, "}": 3, ">": 4 ][character]!
}

try main()
