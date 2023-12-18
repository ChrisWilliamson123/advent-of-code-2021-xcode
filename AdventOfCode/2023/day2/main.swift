import Foundation

struct Round {
    let cubesPulled: [String: Int]

    func isPossible(bag: Bag) -> Bool {
        for (key, value) in bag.contents {
            if let pulled = cubesPulled[key], pulled > value {
                return false
            }
        }
        return true
    }
}

struct Game {
    let id: Int
    let rounds: [Round]

    func isPossible(bag: Bag) -> Bool {
        for r in rounds where !r.isPossible(bag: bag) {
            return false
        }
        return true
    }

    var maxPulls: [String: Int] {
        rounds.reduce(into: [:], { (current, round) in
            round.cubesPulled.forEach({ (colour, count) in
                current[colour] = max(current[colour] ?? 0, count)
            })
        })
    }
}

struct Bag {
    let contents: [String: Int]
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")

    var games: [Game] = []
    for (index, line) in input.enumerated() {
        let gameContents = line.split(separator: ": ")[1]
        let roundsStrings = gameContents.split(separator: "; ")
        let rounds = roundsStrings.map({ roundString in
            let pulls = roundString.split(separator: ", ")
            let dict: [String: Int] = pulls.reduce(into: [:], {
                let split = $1.split(separator: " ")
                $0[String(split[1])] = Int(split[0])
            })
            return Round(cubesPulled: dict)
        })
        let game = Game(id: index + 1, rounds: rounds)
        games.append(game)
    }

    let bag = Bag(contents: [
        "red": 12,
        "green": 13,
        "blue": 14
    ])

    var total = 0
    var power = 0
    games.forEach {
        if $0.isPossible(bag: bag) { total += $0.id }
        power += $0.maxPulls.values.reduce(1, *)
    }

    print(total, power)
}

Timer.time(main)
