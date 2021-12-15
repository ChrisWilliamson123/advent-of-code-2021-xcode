import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)
    let horizontalPositions = input[0].split(separator: ",").compactMap({ Int($0) })

    let partOneAlignmentValue = horizontalPositions.sorted(by: <)[horizontalPositions.count / 2]

    let partOne = horizontalPositions.reduce(0, { $0 + abs(partOneAlignmentValue - $1) })
    print("Part 1: \(partOne)")

    // Part 2
    let range = horizontalPositions.min()!...horizontalPositions.max()!

    var minimumFuelExpended = Int.max

    for alignmentValue in range {
        let fuelNeeded = calculateFuelNeeded(toMoveTo: alignmentValue, crabs: horizontalPositions)
        if fuelNeeded < minimumFuelExpended {
            minimumFuelExpended = fuelNeeded
        }
    }

    print("Part 2: \(minimumFuelExpended)")
}

private func calculateFuelNeeded(toMoveTo: Int, crabs: [Int]) -> Int {
    crabs.reduce(0, { currentTotal, crabPosition in
        let difference = abs(toMoveTo - crabPosition)
        let fuelExpended = (difference * (difference + 1)) / 2
        return currentTotal + fuelExpended
    })
}

try main()
