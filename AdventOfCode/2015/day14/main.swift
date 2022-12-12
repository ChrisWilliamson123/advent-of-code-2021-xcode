import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let reindeers: [Reindeer] = input.map({
        let regex = Regex("(\\w+) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds.")
        let matches = regex.getMatches(in: $0)
        return .init(name: matches[0], speed: Int(matches[1])!, flightTime: Int(matches[2])!, restTime: Int(matches[3])!)
    })

    print("Part one:", DistanceTravelledRace(reindeers: reindeers).getWinningScore(after: 2503))
    print("Part two:", PointsRace(reindeers: reindeers).getWinningScore(after: 2503))
}

struct DistanceTravelledRace: Race {
    let reindeers: [Reindeer]

    func getWinningScore(after time: Int) -> Int {
        reindeers.map({ $0.getDistanceTravelled(in: time) }).max()!
    }
}

struct PointsRace: Race {
    let reindeers: [Reindeer]

    func getWinningScore(after time: Int) -> Int {
        var reindeers = self.reindeers
        for i in 1...time {
            let distances = reindeers.map({ $0.getDistanceTravelled(in: i) })
            let max = distances.max()!
            for index in 0..<distances.count {
                if distances[index] == max {
                    reindeers[index].score += 1
                }
            }
        }
        return reindeers.max(by: { $0.score < $1.score })!.score
    }
}

protocol Race {
    var reindeers: [Reindeer] { get }
    func getWinningScore(after time: Int) -> Int
}

struct Reindeer {
    let name: String
    let speed: Int
    let flightTime: Int
    let restTime: Int

    var score: Int = 0

    // Have time windows of flight time + rest time
    // e.g. 10s + 127s = 137s
    // For each window dT = speed * flight time
    // If not a complete window, dT = max(time - flightTime, time) * speed
    func getDistanceTravelled(in time: Int) -> Int {
        let fullWindowTime = (flightTime + restTime)
        let fullWindows = time / fullWindowTime
        let dTFullWindows = speed * fullWindows * flightTime

        let nonFullWindowTime = time % fullWindowTime
        let dTNonFullWindow: Int
        if nonFullWindowTime > flightTime {
            dTNonFullWindow = speed * flightTime
        } else {
            dTNonFullWindow = speed * nonFullWindowTime
        }

        return dTFullWindows + dTNonFullWindow
    }
}

Timer.time(main)
