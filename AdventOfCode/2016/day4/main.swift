import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let rooms: [Room] = input.map({
        let split = $0.split(separator: "-")
        let name = split[0..<split.count-1].joined(separator: "-")
        let regex = Regex("(\\d+)\\[(\\w+)\\]")
        let matches = regex.getMatches(in: String(split.last!))

        return Room(name: name, sectorID: Int(matches[0])!, checksum: matches[1])
    })

    print("Part one:", rooms.reduce(0, { $1.isReal ? $0 + $1.sectorID : $0 }))
    let northPoleRoom = rooms.first(where: { $0.decryptedName == "northpole object storage" })!
    print("Part two:", northPoleRoom.sectorID)
}

struct Room {
    let name: String
    let sectorID: Int
    let checksum: String

    var isReal: Bool {
        let expectedChecksum = name.characterCounts
            .filter({ $0.key != "-" })
            .sorted(by: { $0.value > $1.value }, { $0.key < $1.key })
            .map({ String($0.key) })
            .prefix(upTo: 5)
            .joined()
        return expectedChecksum == checksum
    }

    var decryptedName: String {
        name.reduce("", { $0 + decryptCharacter($1) })
    }

    private func decryptCharacter(_ char: Character) -> String {
        if char == "-" { return " " }
        let index = Alphabet.charsToIndexes[char]!
        let shiftedIndex = (index + sectorID) % 26
        return Alphabet.indexesToChars[shiftedIndex]!
    }
}

struct Alphabet {
    static let charsToIndexes: [Character: Int] = ["a": 0,
                                                   "b": 1,
                                                   "c": 2,
                                                   "d": 3,
                                                   "e": 4,
                                                   "f": 5,
                                                   "g": 6,
                                                   "h": 7,
                                                   "i": 8,
                                                   "j": 9,
                                                   "k": 10,
                                                   "l": 11,
                                                   "m": 12,
                                                   "n": 13,
                                                   "o": 14,
                                                   "p": 15,
                                                   "q": 16,
                                                   "r": 17,
                                                   "s": 18,
                                                   "t": 19,
                                                   "u": 20,
                                                   "v": 21,
                                                   "w": 22,
                                                   "x": 23,
                                                   "y": 24,
                                                   "z": 25]

    static let indexesToChars: [Int: String] = [0: "a",
                                                1: "b",
                                                2: "c",
                                                3: "d",
                                                4: "e",
                                                5: "f",
                                                6: "g",
                                                7: "h",
                                                8: "i",
                                                9: "j",
                                                10: "k",
                                                11: "l",
                                                12: "m",
                                                13: "n",
                                                14: "o",
                                                15: "p",
                                                16: "q",
                                                17: "r",
                                                18: "s",
                                                19: "t",
                                                20: "u",
                                                21: "v",
                                                22: "w",
                                                23: "x",
                                                24: "y",
                                                25: "z"]
}

Timer.time(main)
