import Foundation

enum HandType: Int {
    case fiveOfAKind = 0
    case fourOfAKind = 1
    case fullHouse = 2
    case threeOfAKind = 3
    case twoPair = 4
    case onePair = 5
    case highCard = 6
}

struct Hand {
    let cards: [Int]
    let bid: Int

    var type: HandType {
        let counts = cards.counts
        print(counts)
        let numberOfJokers = counts[1] ?? 0
        let maxCount = counts.values.max()!
        if maxCount == 5 {
            return .fiveOfAKind
        }

        if maxCount == 4 {
            if numberOfJokers == 1 {
                return .fiveOfAKind
            }
            if numberOfJokers == 4 {
                return .fiveOfAKind
            }
            return .fourOfAKind
        }

        if maxCount == 3 {
            // JJJXX == fioak
            if counts.values.contains(2) && numberOfJokers == 3 {
                return .fiveOfAKind
            }
            // JJJXY == fooak
            if numberOfJokers == 3 {
                return .fourOfAKind
            }
            // XXXJJ == fioak
            if numberOfJokers == 2 {
                return .fiveOfAKind
            }
            // XXXJY == fooak
            if numberOfJokers == 1 {
                return .fourOfAKind
            }
            // Make up a full house
            // XXXYY
            if counts.values.contains(2) {
                return .fullHouse
            }
            // Three of a kind
            return .threeOfAKind
        }

        // XXYYZ
        if counts.values.filter({ $0 == 2 }).count == 2 {
            // Can make up a four of a kind as one of the pairs is jokers
            // XXJJY
            if numberOfJokers == 2 {
                return .fourOfAKind
            }
            // Can make up a full house by using the single joker to make up a three
            // XXJYY
            if numberOfJokers == 1 {
                return .fullHouse
            }
            return .twoPair
        }

        // XXABC
        if counts.values.filter({ $0 == 2 }).count == 1 {
            // JJABC
            if numberOfJokers == 2 {
                return .threeOfAKind
            }
            // Can make up a three of a kind
            // XXJBC
            if numberOfJokers == 1 {
                return .threeOfAKind
            }
            return .onePair
        }

        if numberOfJokers == 1 {
            return .onePair
        }

        return .highCard
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let cardMap = [
        "A": 14,
        "K": 13,
        "Q": 12,
        "J": 1,
        "T": 10
    ]

    let hands = input.map { line in
        let split = line.split(separator: " ")
        let bid = Int(split[1])!
        let cards = split[0].map { character in
            return cardMap[String(character)] ?? Int(character)!
        }
        return Hand(cards: cards, bid: bid)
    }

    for h in hands {
        print(h.cards, h.type)
    }

    // swiftlint:disable:next line_length
    let ordered = hands.sorted(by: { $0.type.rawValue < $1.type.rawValue }, { $0.cards[0] > $1.cards[0] }, { $0.cards[1] > $1.cards[1] }, { $0.cards[2] > $1.cards[2] }, { $0.cards[3] > $1.cards[3] }, { $0.cards[4] > $1.cards[4] })

    print(ordered)

    var total = 0

    for (index, hand) in ordered.enumerated() {
        total += (hand.bid * (ordered.count - index))
    }

    print(total)
}

Timer.time(main)
