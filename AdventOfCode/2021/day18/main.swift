import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let inputCombos = input.combinations(count: 2)

    var maximum = Int.min
    for c in inputCombos {

        var latest = c[0]
        for i in 1..<c.count {

            let added = "[\(latest),\(c[i])]"

            enum Action {
                case explode
                case split
                case addition
                case none
            }

            var previousAction = (added, Action.addition)

            func performActions(_ action: Action, snailfish: String) -> (String, Action) {
                var snailfishNumbers = snailfish
                var depth = 0
                var index = 0

                var actionToReturn = Action.none
                while index < snailfishNumbers.count {
                    if depth == 5 {
                        // Get start of first pair and explode it
                        if Int(snailfishNumbers[index]) == nil {
                            var intCharIndex = index + 1
                            while Int(snailfishNumbers[intCharIndex]) == nil {
                                intCharIndex += 1
                            }
                            index = intCharIndex
                        }
                        let exploder = Exploder(input: snailfishNumbers, index: index)
                        snailfishNumbers = exploder.explode()

                        index = 0
                        depth = 0
                        actionToReturn = .explode
                        continue
                    }
                    let nextChar: String = snailfishNumbers[index]

                    var asInt = Int(nextChar)
                    switch nextChar {
                    case "[": depth += 1
                    case "]": depth -= 1
                    default:
                        if asInt != nil {
                            // Get to the end of the number
                            var intIndex = index + 1
                            while Int(snailfishNumbers[intIndex]) != nil {
                                intIndex += 1
                            }
                            asInt = Int(snailfishNumbers[index..<intIndex])

                            if action == .split && asInt! >= 10 {
                                let replacement = "[\(Int(floor(Double(asInt!)/2))),\(Int(ceil(Double(asInt!)/2)))]"

                                snailfishNumbers = snailfishNumbers[0..<index] + replacement + snailfishNumbers[intIndex..<snailfishNumbers.count]

                                index = 0
                                depth = 0
                                actionToReturn = .split
                                continue
                            }
                        }
                    }
                    index += 1
                }
                return (snailfishNumbers, actionToReturn)

            }

            while previousAction.1 != .none {
                previousAction = performActions(.explode, snailfish: previousAction.0)
                previousAction = performActions(.split, snailfish: previousAction.0)
            }

            latest = previousAction.0
        }
        let mag = getMagnitude(of: latest)
        maximum = max(maximum, mag)
    }

    print(maximum)
}

struct Exploder {
    let input: String
    let index: Int
    func explode() -> String {
        // Get the range of the exploding pair
        let pair = getExplodingPair()
        let lhs = input[0..<pair.range.lowerBound-1]
        let rhs = input[pair.range.upperBound+1..<input.count]

        let lhsNumber = getFirstNumber(in: lhs, start: lhs.count-1, direction: -1)
        let rhsNumber = getFirstNumber(in: rhs, start: 0, direction: 1)

        let newLhs: String
        if let lhsNumber = lhsNumber {
            newLhs = lhs[0..<lhsNumber.1.lowerBound] + "\(lhsNumber.0 + pair.lhs)" + lhs[lhsNumber.1.upperBound-1..<lhs.count]
        } else {
            newLhs = lhs
        }

        let newRhs: String
        if let rhsNumber = rhsNumber {
            newRhs = rhs[0..<rhsNumber.1.lowerBound] + "\(rhsNumber.0 + pair.rhs)" + rhs[rhsNumber.1.upperBound-1..<rhs.count]
        } else {
            newRhs = rhs
        }

        let toReturn = newLhs + "0" + newRhs
        return toReturn
    }

    private func getExplodingPair() -> ExplodingPairResult {
        var pairEndIndex = index + 3
        while input[pairEndIndex] != "]" {
            pairEndIndex += 1
        }

        let pairString = input[index..<pairEndIndex]
        let numberSplit = pairString.split(separator: ",")
        let lhs = Int(numberSplit[0])!
        let rhs = Int(numberSplit[1])!

        return .init(range: index...pairEndIndex, lhs: lhs, rhs: rhs)
    }

    struct ExplodingPairResult {
        let range: ClosedRange<Int>
        let lhs: Int
        let rhs: Int
    }
}

private func getMagnitude(of input: String) -> Int {
    var input = input
    while input.contains("[") {
        let numberPairRegex = Regex("\\[(\\d+),(\\d+)\\]")
        let matches = numberPairRegex.getMatches(in: input, includeFullLengthMatch: true)
        let lhs = Int(matches[1])!
        let rhs = Int(matches[2])!
        let mag = (lhs * 3) + (rhs * 2)
        input = input.replacingOccurrences(of: "[\(lhs),\(rhs)]", with: "\(mag)")
    }
    return Int(input)!
}

extension String {
    func replace(index: Int, with: String) -> String {
        return String(prefix(index)) + with + String(dropFirst(index+1))
    }
}

private func getFirstNumber(in input: String, start: Int, direction: Int) -> (Int, ClosedRange<Int>)? {
    var currentIndex = start + direction
    while (currentIndex >= 0 && currentIndex < input.count) && Int(input[currentIndex]) == nil {
        currentIndex += direction
    }

    if currentIndex < 0 || currentIndex == input.count {
        return nil
    }

    var numberEndIndex = currentIndex + direction
    while Int(input[numberEndIndex]) != nil {
        numberEndIndex += direction
    }

    if numberEndIndex < currentIndex {
        return (Int(input[numberEndIndex+1..<currentIndex+1])!, numberEndIndex+1...currentIndex+2)
    } else {
        return (Int(input[currentIndex..<numberEndIndex])!, currentIndex...numberEndIndex+1)
    }
}

extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

Timer.time(main)
