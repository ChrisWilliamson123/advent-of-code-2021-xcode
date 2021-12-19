import Foundation

//func main() throws {
//    var snailfishNumbers: String = [[[[[9,8],1],2],3],4]
//}
//
//struct Pair {
//
//}

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

private func getFirstNumber(in input: String, start: Int, direction: Int) -> (Int, ClosedRange<Int>)? {
    var currentIndex = start + direction
    while (currentIndex >= 0 && currentIndex < input.count) && Int(input[currentIndex]) == nil {
        currentIndex += direction
    }

    if currentIndex < 0 || currentIndex == input.count {
        return nil
    }

//    [[[[4,0],[5,4]],[[7,7],[6,0]]],[[[6,6],[5,5]],[[0,[[5,5],[5,5]]],[0,6]]]]

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

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
//
//    print(input)

//    var snailfishNumbers: String = "[[[[[9,8],1],2],3],4]"
//    let exploder = Exploder(input: snailfishNumbers, index: 5)
//    exploder.explode()
//    assert(false)

//    var snailfishNumbers: String = "[7,[6,[5,[4,[3,2]]]]]"
//    let exploder = Exploder(input: snailfishNumbers, index: 13)
//    exploder.explode()
//    assert(false)

//    var snailfishNumbers: String = "[[6,[5,[4,[3,2]]]],1]"
//    let exploder = Exploder(input: snailfishNumbers, index: 11)
//    exploder.explode()
//    assert(false)

//    var snailfishNumbers: String = "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"
//    let exploder = Exploder(input: snailfishNumbers, index: 11)
//    exploder.explode()
//    assert(false)

//    var snailfishNumbers: String = "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"
//    let exploder = Exploder(input: snailfishNumbers, index: 25)
//    exploder.explode()
//    assert(false)
//    var snailfishNumbers: String = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"



//    let inputs: [String] = [
//        "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]",
//        "[[[5,[2,8]],4],[5,[[9,9],0]]]",
//        "[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]",
//        "[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]",
//        "[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]",
//        "[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]",
//        "[[[[5,4],[7,7]],8],[[8,3],8]]",
//        "[[9,3],[[9,9],[6,[4,9]]]]",
//        "[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]",
//        "[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"
//    ]


    var inputCombos = input.combinations(count: 2)

    var maximum = Int.min
    for c in inputCombos {

        var latest = c[0]
        for i in 1..<c.count {

            var added = "[\(latest),\(c[i])]"

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
                        //                        snailfishNumbers = explode(input: snailfishNumbers, index: index)
//                        print("After explode: ", snailfishNumbers)
                        index = 0
                        depth = 0
                        actionToReturn = .explode
                        continue
                    }
                    let nextChar: String = snailfishNumbers[index]
                    //            print(index, depth, nextChar)
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
                                //                        snailfishNumbers = snailfishNumbers.replace(index: index, with: replacement)
                                snailfishNumbers = snailfishNumbers[0..<index] + replacement + snailfishNumbers[intIndex..<snailfishNumbers.count]
//                                print("After split: ", snailfishNumbers)
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
//            print(latest)
        }
        let mag = getMagnitude(of: latest)
//        print(mag)
        maximum = max(maximum, mag)
    }

    print(maximum)

//    print(previousAction.0)
}

private func getMagnitude(of input: String) -> Int {
    var input = input
    while input.contains("[") {
        let numberPairRegex = Regex("\\[(\\d+),(\\d+)\\]")
        let matches = numberPairRegex.getMatches(in: input, includeFullLengthMatch: true)
//        print(matches)
//        let match = matches[0]
//        let split = match.split(separator: ",")
        let lhs = Int(matches[1])!
        let rhs = Int(matches[2])!
        let mag = (lhs * 3) + (rhs * 2)
        input = input.replacingOccurrences(of: "[\(lhs),\(rhs)]", with: "\(mag)")
//        print("i", input)
    }
    return Int(input)!
}

private func explode(input: String, index: Int) -> String {
    var lhsNumberIndex = index+1
    while Int(input[lhsNumberIndex]) != nil {
        lhsNumberIndex += 1
    }
//    var rhsNumberIndex = lhsNumberIndex + 1
//    while Int(input[rhsNumberIndex]) != nil {
//        rhsNumberIndex += 1
//    }
    let lhs = input[0..<lhsNumberIndex]
    let rhs = input[lhsNumberIndex+1..<input.count]
//    print("here")

    func buildLhs(from: String, depth: Int, numberLength: Int) -> String {
//        print(numberLength)
        var output = from[from.count - 3] == "[" ? from[0..<from.count-2] + from[from.count-1] : from[0..<from.count - 3]
//        print("output", output)

        if let numberToLeft = getFirstNumber(numbers: from, start: from.count - 1, direction: -1, depth: 5) {

//            let newNumber = Int(from[from.count-1])! + numberToLeft.0
//            var newNumberIndex = numberToLeft.1
//
//            var toReturn = from[0..<from.count-2]
//            if toReturn[toReturn.count-1] == "," { toReturn = toReturn[0..<toReturn.count-1] }
//            else { toReturn = toReturn + "0"; }
//
//            return toReturn.replace(index: newNumberIndex, with: "\(newNumber)")
        } else {
            // There's no number to the right, so remove a bracket from the end and change number to 0
//            return (from[1..<from.count-1] + "0")
//            return output.repl
        }
        return ""
    }

    func buildRhs(from: String, depth: Int, numberLength: Int) -> String {
        if let numberToRight = getFirstNumber(numbers: from, start: 0, direction: 1, depth: 5) {
            let newNumber = Int(from[0])! + numberToRight.0
            var newNumberIndex = numberToRight.1 - 2

            var toReturn = from[2..<from.count]
            if toReturn[0] == "," { toReturn = toReturn[1..<from.count]; newNumberIndex -= 1 }
            else { toReturn = "0" + toReturn; newNumberIndex += 1 }
            return toReturn.replace(index: newNumberIndex, with: "\(newNumber)")
        } else {
            // There's no number to the right, so remove a bracket from the end and change number to 0
            return ("0" + from[1..<from.count-1])
        }
    }

    let newLhs = buildLhs(from: lhs, depth: 5, numberLength: 2)
    let newRhs = buildRhs(from: rhs, depth: 5, numberLength: 2)

    return newLhs + "," + newRhs
}

extension String {
    func replace(index: Int, with: String) -> String {
        return String(prefix(index)) + with + String(dropFirst(index+1))
    }
}

private func getFirstNumber(numbers: String, start: Int, direction: Int, depth: Int) -> (Int, Int)? {
    let depthReducer = direction == 1 ? "]" : "["
    var index = start + direction
    var depth = depth
    while index < numbers.count && index >= 0 && depth > 0 {
        let nextChar: String = numbers[index]
        if nextChar == depthReducer {
            depth -= 1
            index += direction
            continue
        }
        if let asInt = Int(nextChar) {
            // Get to the end of that int then return it
            var intIndex = index+direction
            while Int(numbers[intIndex]) != nil {
                intIndex += direction
            }
            if intIndex < index {
                return (Int(numbers[intIndex+1..<index+1])!, index)
            } else {
                return (Int(numbers[index..<intIndex])!, index)
            }
        }
        index += direction
    }

    return nil
}

extension Array {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

try main()

