import Foundation

func main() throws {
    let input: String = try readInput(fromTestFile: false)[0]

    func expand(input: String, count: Int) -> Int {
        if !input.contains("(") { return input.count * count }

        // Else, we need to do more expansions
        var expandedStringLength = 0
        var index = 0
        while index < input.count {
            let nextChar = input[index]
            guard nextChar == "(" else { index += 1; expandedStringLength += 1; continue }

            var markerIndex = index + 1
            while input[markerIndex] != ")" { markerIndex += 1 }
            let nextMarker = input[index...markerIndex]

            let split = Regex("\\((\\d+)x(\\d+)\\)").getMatches(in: nextMarker)
            let decompressionLength = Int(split[0])!
            let decompressionMultiplier = Int(split[1])!

            let toReplace = input[markerIndex+1...markerIndex+decompressionLength]
            let expansion = expand(input: toReplace, count: decompressionMultiplier)
            expandedStringLength += expansion
            index += nextMarker.count + decompressionLength
        }

        return expandedStringLength * count
    }

    print(expand(input: input, count: 1))
}

try main()
