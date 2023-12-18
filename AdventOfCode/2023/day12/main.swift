import Foundation
import Algorithms

func replaceInString(string: String, new: Character, location: Int) -> String {
    var toReturn = [Character](string)
    toReturn[location] = new
    return String(toReturn)
}

func replaceInString(string: String, new: Character, range: Range<Int>) -> String {
    var toReturn = [Character](string)
    for i in range {
        toReturn[i] = new
    }
    return String(toReturn)
}

var cache: [State: Int] = [:]

struct State: Hashable {
    let line: String
    let index: Int
    let groups: [Int]

    var currentCharacter: Character { line[index] }

    var nextStates: Set<State> {
        // If a group has just ended
        if groups.first == 0 {
            var newGroups = groups
            _ = newGroups.remove(at: 0)
            if currentCharacter == "#" {
                return []
            }
            if index == line.count - 1 {
                return [State(line: line, index: index + 1, groups: newGroups)]
            }
            if currentCharacter == "." || currentCharacter == "?" {
                return [State(line: line, index: index + 1, groups: newGroups)]
            }
        }
        // If we're a '.', continue to next character
        if currentCharacter == "." {
            return [State(line: line, index: index + 1, groups: groups)]
        }

        // If we're a '#', remove one from group
        if currentCharacter == "#" {
            if groups.first == nil {
                return []
            }
            let leftInGroup = groups[0]
            let substring = line[index..<index+leftInGroup]
            if substring.count != leftInGroup {
                return []
            }
            if substring.contains(where: { $0 != "#" && $0 != "?" }) {
                return []
            }
            // Can remove one from group
            var groupsCopy = groups
            groupsCopy[0] = 0
            return [State(line: line, index: index + leftInGroup, groups: groupsCopy)]
        }

        // If we're a '?' character
        if currentCharacter == "?" {
            // treat as dot
            if groups.isEmpty {
                return [State(line: line, index: index + 1, groups: groups)]
            }
            // Treat as hash and dot
            var total: Set<State> = []

            // Hash
            let leftInGroup = groups[0]
            let substring = line[index..<index+leftInGroup]
            if substring.count != leftInGroup {

            } else if substring.contains(where: { $0 != "#" && $0 != "?" }) {

            } else {
                // Can remove one from group
                var groupsCopy = groups
                groupsCopy[0] = 0
                total.insert(State(line: line, index: index + leftInGroup, groups: groupsCopy))
            }

            // Dot
            total.insert(State(line: line, index: index + 1, groups: groups))
            return total
        }

        assert(false, "Shouldn't reach here")
    }
}

// var all: Set<String> = []

private func solve(state: State) -> Int {
    if let existing = cache[state] {
        return existing
    }

    let line = state.line
    let index = state.index
    let groups = state.groups

    // Always going to trying to focus on the group at index 0

    // If we're at the end of a line and no groups, we have a valid solution, if still groups, no soltution
    if index >= line.count {
        if groups.isEmpty || (groups.count == 1 && groups[0] == 0) {
            cache[state] = 1
            return 1
        } else {
            cache[state] = 0
            return 0
        }
    }

    // Now we need to get next states
    var total = 0
    let next = state.nextStates
    for n in next {
        total += solve(state: n)
    }
    cache[state] = total
    return total
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    var tot = 0

    for line in input {
        let split = line.split(separator: " ")
        let record = String([split[0], split[0], split[0], split[0], split[0]].joined(by: "?"))
        let groups = Array(repeating: split[1].split(separator: ",").map({ Int($0)! }), count: 5).flatMap(({ $0 }))
        let result = solve(state: State(line: String(record), index: 0, groups: groups))
        tot += result
    }

    print(tot)
}

Timer.time(main)
