import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    // Part 1
    let gammaRate = getGammaRate(from: input)
    let epsilonRate = flipBits(of: gammaRate, numberOfBitsToFlip: input[0].count)
    print("Part 1: \(gammaRate * epsilonRate)")

    // Part 2
    var oxygenRatings = input
    var scrubberRatings = input
    
    var columnIndex = 0
    while (oxygenRatings.count > 1 || scrubberRatings.count > 1) && columnIndex < input[0].count {
        oxygenRatings = filterRatings(oxygenRatings, underColumn: columnIndex, defaultBit: "1")
        scrubberRatings = filterRatings(scrubberRatings, underColumn: columnIndex, defaultBit: "0")
        
        columnIndex += 1
    }

    let oxygenDecimal = Int(oxygenRatings[0], radix: 2)!
    let scrubberDecimal = Int(scrubberRatings[0], radix: 2)!

    print("Part 2: \(oxygenDecimal * scrubberDecimal)")
}

private func filterRatings(_ ratings: [String], underColumn columnIndex: Int, defaultBit: Character) -> [String] {
    if ratings.count == 1 { return ratings }
    let binaryColumn = getColumn(from: ratings, at: columnIndex)
        
    /// -1 if 0 is most common, 0 if equal commonality, 1 if 1 is most common
    let mostCommonSumResult = binaryColumn.reduce(0, { currentSum, bit in
        let modifier = bit == "0" ? -1 : 1
        return currentSum + modifier
    })
    let keeperBit: Character
    if mostCommonSumResult == 0 {
        keeperBit = defaultBit
    } else {
        keeperBit = mostCommonSumResult > 0 ? defaultBit : flipBitCharacter(defaultBit)
    }

    return ratings.filter({
        let index = $0.index($0.startIndex, offsetBy: columnIndex)
        let binaryChar = $0[index]
        return binaryChar == keeperBit
    })
}

private func flipBitCharacter(_ character: Character) -> Character {
    character == "0" ? "1" : "0"
}

private func getGammaRate(from report: [String]) -> UInt {
    let gammaRateBinaryString = (0..<report[0].count).reduce("", { currentBinaryString, columnIndex in
        let binaryColumn: [Character] = getColumn(from: report, at: columnIndex)
        let mostCommonBit = Int(getMostCommonCharacter(from: binaryColumn))!

        return currentBinaryString + String(mostCommonBit)
    })

    return UInt(gammaRateBinaryString, radix: 2)!
}

private func flipBits(of input: UInt, numberOfBitsToFlip: Int) -> UInt {
    input ^ ((UInt(1) << numberOfBitsToFlip) - 1)
}

private func getColumn(from stringArray: [String], at index: Int) -> [Character] {
    stringArray.map({ $0[$0.index($0.startIndex, offsetBy: index)] })
} 

private func getMostCommonCharacter(from characters: [Character]) -> Character {
    let countedSet = NSCountedSet(array: characters)
    let mostFrequent = countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) }
    return mostFrequent as! Character
}

Timer.time(main)
