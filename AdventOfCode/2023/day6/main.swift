import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")

    let regex = Regex("\\d+")
    let times = regex.getGreedyMatches(in: input[0]).compactMap({ Int($0) })
    let distances = regex.getGreedyMatches(in: input[1]).compactMap({ Int($0) })
    let races = zip(times, distances)

    var total = 1
    for r in races {
        let raceTime = Double(r.0)
        let distance = Double(r.1)
        let sq = pow(Double(raceTime), 2)
        let fourAC = Double(4 * -1 * -distance)
        let sqrt = sqrt(sq - fourAC)
        let plusResult = (-raceTime + sqrt) / -2
        let minusResult = (-raceTime - sqrt) / -2

        total *= Int(abs(floor(plusResult+1) - ceil(minusResult-1)) + 1)
    }
    print(total)
}

Timer.time(main)
