import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)
    
    var numberOfOutputDigitsThatUseUniqueNumberOfSegments = 0
    let uniqueSegmentAmounts = [2, 4, 3, 7]

    for l in input {
        let outputValue = l.split(separator: "|")[1].split(separator: " ")
        numberOfOutputDigitsThatUseUniqueNumberOfSegments += outputValue.reduce(0, { uniqueSegmentAmounts.contains($1.count) ? $0 + 1 : $0 })
    }

    print("Part 1: \(numberOfOutputDigitsThatUseUniqueNumberOfSegments)")

    var outputs: [Int] = []
    for i in input {
        let decoder = SegmentDecoder(i)
        let output = decoder.decodeSegments()
        outputs.append(output)
    }
    print("Part 2: \(outputs.sum())")
    
}

class SegmentDecoder {
    /*
       0
      1 2
       3
      4 5
       6
    */
    var segmentsWithPossibleLetters: [[Character]] = Array(repeating: [Character]("abcdefg"), count: 7)
    let signalPatterns: [String]
    let outputValue: [String]

    let digitsToSegmentIndexes: [[(Int, [Int])]] = [
        [(1, [2, 5])],
        [(7, [0, 2, 5])],
        [(4, [1, 2, 3, 5])],
        [(8, [0, 1, 2, 3, 4, 5, 6])],
        [(3, [0, 2, 3, 5, 6]), (2, [0, 2, 3, 4, 6]), (5, [0, 1, 3, 5, 6])],
        [(0, [0, 1, 2, 4, 5, 6]), (6, [0, 1, 3, 4, 5, 6]), (9, [0, 1, 2, 3, 5, 6])]
    ]

    init(_ input: String) {
        signalPatterns = input.split(separator: "|")[0].split(separator: " ").map({ String($0) })
        outputValue = input.split(separator: "|")[1].split(separator: " ").map({ String($0) })
    }

    func decodeSegments() -> Int {
        for sameLengthCluster in digitsToSegmentIndexes where sameLengthCluster.count == 1 {
            for (_, segmentIndexes) in sameLengthCluster {
                let matchingSignalPattern = signalPatterns.filter({ $0.count == segmentIndexes.count })[0]

                // Remove values from other segments that aren't the ones for this digit
                let unusedSegmentIndexes = [0, 1, 2, 3, 4, 5, 6].filter({ !segmentIndexes.contains($0) })
                for unusedSegmentIndex in unusedSegmentIndexes {
                    segmentsWithPossibleLetters[unusedSegmentIndex] = segmentsWithPossibleLetters[unusedSegmentIndex].filter({ !matchingSignalPattern.contains($0) })
                }

                // For each segment of the digit, keep letters that exist within the signal pattern
                for segmentIndex in segmentIndexes {
                    segmentsWithPossibleLetters[segmentIndex] = segmentsWithPossibleLetters[segmentIndex].filter({ matchingSignalPattern.contains($0) })
                }
            }
        }

        for sameLengthCluster in digitsToSegmentIndexes where sameLengthCluster.count > 1 {
            // Get the indexes of the segments in common between the numbers in this cluster
            // e.g. 3, 2 and 5 all share segments 0, 3 and 6
            var segmentsInCommon: [Int] = []
            [0, 1, 2, 3, 4, 5, 6].forEach { s in
                for (_, indexes) in sameLengthCluster {
                    if !indexes.contains(s) { return }
                }
                segmentsInCommon.append(s)
            }

            // Get the signal patterns that exist for the length of each item in the cluster
            // e.g. for the cluster that contains digits who have 5 segments (2, 3, 5), there should be three matching signal patterns
            let matchingSignalPatterns = signalPatterns.filter({ $0.count == sameLengthCluster[0].1.count })

            // Loop through the segments in common whose definitive value still haven't been determined
            for s in segmentsInCommon where segmentsWithPossibleLetters[s].count > 1 {
                let possibleValuesForSegment = segmentsWithPossibleLetters[s]
                
                // Get the possible values which appear in all matching signal patterns
                var valuesThatAppearInAllSignals: [Character] = []
                for v in possibleValuesForSegment {
                    if matchingSignalPatterns.filter({ $0.contains(v) }).count == matchingSignalPatterns.count {
                        valuesThatAppearInAllSignals.append(v)
                    }
                }

                // If one value was found for the segment...
                if valuesThatAppearInAllSignals.count == 1 {
                    // Set the value on the segment
                    segmentsWithPossibleLetters[s] = [valuesThatAppearInAllSignals[0]]

                    // Remove the value as a possibility from other segments
                    for i in 0..<segmentsWithPossibleLetters.count where segmentsWithPossibleLetters[i].contains(valuesThatAppearInAllSignals[0]) && segmentsWithPossibleLetters[i].count > 1  {
                        segmentsWithPossibleLetters[i] = segmentsWithPossibleLetters[i].filter({ $0 != valuesThatAppearInAllSignals[0] })
                    }
                }
            }
        }


        // Using the segments with their definitive letter values, loop through the output strings and get the number for them
        var outputValueNumbers: [Int] = []
        for o in outputValue {
            let segmentsLitUp = (0..<segmentsWithPossibleLetters.count).filter({
                let letter = segmentsWithPossibleLetters[$0][0]
                return o.contains(letter)
            })
            
            let associatedDigit = digitsToSegmentIndexes.flatMap({ $0 }).filter({
                $0.1.sorted() == segmentsLitUp.sorted()
            })[0].0

            outputValueNumbers.append(associatedDigit)
        }
        return Int(outputValueNumbers.map({ String($0) }).joined())!
    }

    private func printSegments() {
        for i in 0..<segmentsWithPossibleLetters.count {
            print(i, segmentsWithPossibleLetters[i])
        }
        print("\n")
    }
}

try main()
