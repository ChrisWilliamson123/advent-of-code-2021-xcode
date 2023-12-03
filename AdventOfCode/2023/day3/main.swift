import Foundation

struct Number {
    let value: Int
    let positions: Set<Coordinate>
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    
    var numbers: [Number] = []
    
    for (y, line) in input.enumerated() {
        let regex = Regex("\\d+")
        let matches = regex.getGreedyMatchesWithRanges(in: line)
        for (numberString, range) in matches {
            numbers.append(Number(value: Int(numberString)!, positions: range.reduce(into: Set<Coordinate>(), { $0.insert(Coordinate($1, y)) })))
        }
    }
    
    let grid: [[String]] = input.map { $0.split(separator: "").map({ String($0) }) }
    
    var total = 0
    var total2 = 0
    for (y, row) in grid.enumerated() {
        for (x, character) in row.enumerated() {
            let coord = Coordinate(x, y)
            let regex = Regex("\\d|\\.")
            let matches = regex.getGreedyMatches(in: character)
            print(character, matches)
            if matches.isEmpty {
                // It is a symbol
                let adjacents = coord.getAdjacents(in: grid)
                for n in numbers {
                    if !n.positions.intersection(adjacents).isEmpty {
                        total += n.value
                    }
                }
                
                if character == "*" {
                    // it is a gear, find out if it has exactly two numbers
                    var neighbours: [Number] = []
                    for n in numbers {
                        if !n.positions.intersection(adjacents).isEmpty {
                            neighbours.append(n)
                        }
                    }
                    
                    if neighbours.count == 2 {
                        total2 += neighbours.reduce(1, { $0 * $1.value })
                    }
                }
            }
        }
    }
    print(total, total2)
}

Timer.time(main)
