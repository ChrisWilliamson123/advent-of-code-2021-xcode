import Foundation

let charToInt: [Character: Int] = [
    "a": 0,
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

let intToChar = [0: "a",
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

func main() throws {
    var currentPassword: [Int] = [Character]("hxbxwxba").map({ charToInt[$0]! })
    while !passwordIsValid(currentPassword) {
        currentPassword = incrementPassword(currentPassword)
    }

    print("Part one: ", terminator: "")
    printPassword(currentPassword)

    currentPassword = incrementPassword(currentPassword)
    while !passwordIsValid(currentPassword) {
        currentPassword = incrementPassword(currentPassword)
    }

    print("Part two: ", terminator: "")
    printPassword(currentPassword)
}

private func passwordIsValid(_ password: [Int]) -> Bool {
    if password.contains(where: { $0 == 8 || $0 == 14 || $0 == 11 }) { return false }
    var hasStraight = false
    for i in 2..<password.count {
        let straight = Array(password[i-2...i])
        if straight[1] == straight[0] + 1 && straight[2] == straight[1] + 1 {
            hasStraight = true
            break
        }
    }
    if !hasStraight { return false }

    var pairs: [String] = []
    for i in 1..<password.count {
        pairs.append([password[i-1], password[i]].map({ intToChar[$0]! }).joined())
    }
    var indexesOfPairs: [String: [Int]] = [:]
    for i in 0..<pairs.count {
        indexesOfPairs[pairs[i]] = indexesOfPairs[pairs[i], default: []] + [i]
    }

    let validPairs = indexesOfPairs.filter({ Set([Character]($0.key)).count == 1 })
    if validPairs.count > 1 {
        let values = validPairs.values.flatMap({ $0 })
        if values.max()! - values.min()! > 1 {
            return true
        }
    }
    return false
}

private func incrementPassword(_ password: [Int]) -> [Int] {
    var newPass = password
    let indexToIncrement = password.lastIndex(where: { $0 != 25 })!

    if indexToIncrement != password.count - 1 {
        for i in (indexToIncrement+1..<password.count) {
            newPass[i] = 0
        }
    }
    newPass[indexToIncrement] += 1
    return newPass
}

private func printPassword(_ password: [Int]) {
    print(password.map({ intToChar[$0]! }).joined())
}

Timer.time(main)
