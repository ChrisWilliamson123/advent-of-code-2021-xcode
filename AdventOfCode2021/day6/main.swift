import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let fishAgesString: [String] = try readInput(fromTestFile: isTestMode)
    let initialFishAges: [Int] = fishAgesString[0].split(separator: ",").compactMap({ Int($0) })

    let fishGroup = FishGroup(initialFishSpawnTimes: initialFishAges)
    print("Part 1: \(fishGroup.getNumberOfFishInGroup(after: 80))")
    print("Part 2: \(fishGroup.getNumberOfFishInGroup(after: 256))")
}

class FishGroup {
    private let initialFishSpawnTimes: [Int]

    init(initialFishSpawnTimes: [Int]) {
        self.initialFishSpawnTimes = initialFishSpawnTimes
    }

    func getNumberOfFishInGroup(after timePeriod: Int) -> Int {
        var countsForFishInEachDay = buildInitialDaysList()

        for _ in (0..<timePeriod) {
            let numberOfNewFishToSpawn = countsForFishInEachDay[0]

            for i in (1..<9) {
                countsForFishInEachDay[i-1] = countsForFishInEachDay[i]
            }

            countsForFishInEachDay[6] += numberOfNewFishToSpawn
            countsForFishInEachDay[8] = numberOfNewFishToSpawn
        }

        return countsForFishInEachDay.sum()
    }

    private func buildInitialDaysList() -> [Int] {
        var countsForFishInEachDay: [Int] = Array(repeating: 0, count: 9)

        for spawnTime in initialFishSpawnTimes {
            countsForFishInEachDay[spawnTime] += 1
        }

        return countsForFishInEachDay
    }
}

try main()