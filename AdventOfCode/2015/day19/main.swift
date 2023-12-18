import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")

    let replacements: [String: Set<String>] = input[0].split(separator: "\n").reduce(into: [:], {
        let split = $1.components(separatedBy: " => ")
        $0[split[1]] = $0[split[1], default: []].union([split[0]])
    })

    print(replacements)

    let starter = input[1].replacingOccurrences(of: "\n", with: "")

//    var molecules = Set<String>()
//
//    for (molecule, replacement) in replacements {
//        let indices = starter.indicesOf(string: molecule)
//        for i in indices {
//            for r in replacement {
//                let range = starter.index(starter.startIndex, offsetBy: i)...starter.index(starter.startIndex, offsetBy: i + (molecule.count - 1))
//                molecules.insert(starter.replacingCharacters(in: range, with: r))
//            }
//        }
//    }
//
//    print(molecules.count)

//    let partTwo = dijkstra(graph: ["e"],
//                           source: "e",
//                           target: starter) { inputMolecule in
//        if inputMolecule.count >= starter.count { return [] }
//        return getNextMolecules(for: inputMolecule, rules: replacements, end: starter)
//    } getDistanceBetween: { source, target in
//        1
//    }

    let partTwo = aStar(graph: [starter],
                        source: starter,
                        target: "e") { getNextMolecules(for: $0, rules: replacements, end: starter)
    } getDistanceBetween: { _, _ in
        1
    } heuristicFunction: { source, _ in source.count }

    print(partTwo.distances["e"])
}

private func getNextMolecules(for start: String, rules: [String: Set<String>], end: String) -> Set<String> {
    var molecules = Set<String>()
    let toReplace = start
    for (molecule, replacement) in rules {
        let indices = toReplace.indicesOf(string: molecule)
        for i in indices {
            for r in replacement {
                let range = toReplace.index(toReplace.startIndex, offsetBy: i)...toReplace.index(toReplace.startIndex, offsetBy: i + (molecule.count - 1))
                molecules.insert(toReplace.replacingCharacters(in: range, with: r))
            }
        }
    }

    return molecules
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

Timer.time(main)
