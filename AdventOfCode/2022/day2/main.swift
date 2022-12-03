import Foundation

struct Game {
    let plays: [Decision] = [.rock, .paper, .scissors]

    func next(for play: Decision) -> Decision {
        let playIndex = plays.firstIndex(of: play)!
        let nextIndex = playIndex + 1
        if nextIndex >= plays.count { return plays[0] }
        return plays[nextIndex]
    }

    func prev(for play: Decision) -> Decision {
        let playIndex = plays.firstIndex(of: play)!
        let nextIndex = playIndex - 1
        if nextIndex < 0 { return plays[plays.count-1] }
        return plays[nextIndex]
    }

    func outcome(opponentMove: Decision, meMove: Decision) -> Outcome {
        if opponentMove == meMove { return .draw }
        if next(for: opponentMove) == meMove { return .win }
        return .lose
    }
}

enum Decision {
    case rock
    case paper
    case scissors

    static func fromString(_ string: String) -> Decision {
        switch string {
        case "A", "X": return .rock
        case "B", "Y": return .paper
        case "C", "Z": return .scissors
        default: assertionFailure("Invalid move"); return .rock
        }
    }
}

enum Outcome {
    case win
    case draw
    case lose

    static func fromString(_ string: String) -> Outcome {
        switch string {
        case "X": return .lose
        case "Y": return .draw
        case "Z": return .win
        default: assertionFailure("Invalid move"); return .lose
        }
    }
}

struct Move {
    let opponent: Decision
    let me: Decision

    init(opponent: String, me: String) {
        self.opponent = Decision.fromString(opponent)
        self.me = Decision.fromString(me)
    }

    init(opponent: Decision, me: Decision) {
        self.opponent = opponent
        self.me = me
    }

    var meOutcome: Outcome { Game().outcome(opponentMove: opponent, meMove: me) }

    var myChoiceScore: Int {
        switch me {
        case .rock:     return 1
        case .paper:    return 2
        case .scissors: return 3
        }
    }

    var winScore: Int {
        switch meOutcome {
        case .win:  return 6
        case .draw: return 3
        case .lose: return 0
        }
    }

    var score: Int { myChoiceScore + winScore }
}

struct PredictedMove {
    let opponent: Decision
    let expectedOutcome: Outcome

    init(opponent: String, expectedOutcome: String) {
        self.opponent = Decision.fromString(opponent)
        self.expectedOutcome = Outcome.fromString(expectedOutcome)
    }

    var meMove: Decision {
        switch expectedOutcome {
        case .draw: return opponent
        case .win:
            switch opponent {
            case .rock:
                return .paper
            case .paper:
                return .scissors
            case .scissors:
                return .rock
            }
        case .lose:
            switch opponent {
            case .rock:
                return .scissors
            case .paper:
                return .rock
            case .scissors:
                return .paper
            }
        }
    }

    var move: Move {
        return Move(opponent: opponent, me: meMove)
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let moves = input.map {
        let split = $0.split(separator: " ")
        return Move(opponent: String(split[0]), me: String(split[1]))
    }

    print(moves)
    let scores = moves.map { $0.score }
    let sum = scores.sum()
    print(sum)

    let predictedMoves = input.map {
        let split = $0.split(separator: " ")
        return PredictedMove(opponent: String(split[0]), expectedOutcome: String(split[1]))
    }
    let calculatedMoves = predictedMoves.map { $0.move }
    print(calculatedMoves.map({ $0.score }).sum())
}

extension StringProtocol {
    var asciiValues: [Int] { compactMap(\.asciiValue).map { Int($0) } }
    var asciiValue: Int { asciiValues.first! }
}

try main()
