import Foundation

class RecursiveCombat {
    var decks: [[Int]]
    var seenStates: Set<[[Int]]> = []

    init(decks: [[Int]]) {
        self.decks = decks
    }

    func playGame() {
        while !decks[0].isEmpty && !decks[1].isEmpty {
            playRound()
        }
    }

    func playRound() {
        if seenStates.contains(decks) {
            decks[1] = []
            return
        }

        seenStates.insert(decks)

        let cards = (decks[0].removeFirst(), decks[1].removeFirst())

        var winner = [0, 0]
        if cards.0 <= decks[0].count && cards.1 <= decks[1].count {
            let nextDecks = [Array(decks[0][0..<cards.0]), Array(decks[1][0..<cards.1])]
            let newGame = RecursiveCombat(decks: nextDecks)
            newGame.playGame()
            winner = newGame.getWinState()
        } else {
            if cards.0 > cards.1 {
                winner[0] = 1
            } else {
                winner[1] = 1
            }
        }

        if winner[0] == 1 {
            decks[0].append(contentsOf: [cards.0, cards.1])
        } else {
            decks[1].append(contentsOf: [cards.1, cards.0])
        }
    }

    func getWinState() -> [Int] {
        if decks[0].isEmpty {
            return [0, 1]
        }
        return [1, 0]
    }

    func getWinningScore() -> Int {
        let winner = (decks[0].isEmpty ? decks[1] : decks[0])
        return getScore(for: winner)
    }

    func getScore(for deck: [Int]) -> Int {
        var deck = deck
        var finalScore = 0
        var index = 1
        while let nextCard = deck.popLast() {
            finalScore += nextCard * index
            index += 1
        }

        return finalScore
    }
}

private func buildPlayers(from input: [String]) -> [[Int]] {
    input.map({ inputString in
        inputString.split(separator: "\n").suffix(from: 1).map({ Int($0)! })
    })
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")

    var players: [[Int]] = buildPlayers(from: input)

    while !players[0].isEmpty && !players[1].isEmpty {
        let cards = (players[0].removeFirst(), players[1].removeFirst())
        if cards.0 > cards.1 {
            players[0].append(contentsOf: [cards.0, cards.1])
        } else {
            players[1].append(contentsOf: [cards.1, cards.0])
        }
    }

    var winner = (players[0].isEmpty ? players[1] : players[0])

    var finalScore = 0
    var index = 1
    while let nextCard = winner.popLast() {
        finalScore += nextCard * index
        index += 1
    }

    print("Part one:", finalScore)

    let recursive = RecursiveCombat(decks: buildPlayers(from: input))
    recursive.playGame()
    print("Part two:", recursive.getWinningScore())
}

Timer.time(main)
