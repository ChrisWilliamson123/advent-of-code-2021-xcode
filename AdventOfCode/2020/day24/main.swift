import Foundation

func main() throws {
    let tileDirections: [String] = try readInput(fromTestFile: false)

    // even is white, odd is black
    var tileStates: [Coordinate: Int] = [:]

    for dList in tileDirections {
        let directions = matches(for: "(e)|(se)|(sw)|(w)|(nw)|(ne)", in: dList)

        var current = (0,0)
        for d in directions {
            let m = modifier(for: d)
            current.0 += m.x
            current.1 += m.y
        }
        let final = Coordinate(current.0, current.1)

        tileStates[final] = (tileStates[final] ?? 0) + 1
    }

    print("Part one:", tileStates.values.filter({ $0 % 2 != 0 }).count)

    for _ in 0..<100 {
        var minX = Int.max
        var maxX = Int.min
        var minY = Int.max
        var maxY = Int.min
        for key in tileStates.keys {
            minX = min(minX, key.x)
            maxX = max(maxX, key.x)
            minY = min(minY, key.y)
            maxY = max(maxY, key.y)
        }

        minX -= 2
        maxX += 2
        minY -= 1
        maxY += 1

        var nextState = tileStates
        for y in minY...maxY {
            let minXIsEven = minX % 2 == 0
            let start: Int
            if y % 2 == 0 {
                start = minXIsEven ? minX : minX + 1
            } else {
                start = minXIsEven ? minX + 1 : minX
            }
            let xStride = stride(from: start, to: maxX, by: 2)
            for x in xStride {
                let coord = Coordinate(x, y)
                assert(abs(coord.x % 2) == abs(coord.y % 2))

                let isWhite = (tileStates[coord] ?? 0) % 2 == 0
                let adj = getAdjacents(from: coord)
                let adjacentBlacksCount = adj.filter({
                    if let adjTile = tileStates[$0] {
                        return adjTile % 2 != 0
                    }
                    return false
                }).count

                if isWhite && adjacentBlacksCount == 2 {
                    nextState[coord] = 1
                }

                if !isWhite {
                    if adjacentBlacksCount == 0 || adjacentBlacksCount > 2 {
                        nextState[coord] = 0
                    }
                }

            }

        }
        tileStates = nextState
    }
    print("Part two:", tileStates.values.filter({ $0 % 2 != 0 }).count)
}

private func modifier(for direction: String) -> Coordinate {
    switch direction {
    case "e": return Coordinate(2, 0)
    case "se": return Coordinate(1, -1)
    case "ne": return Coordinate(1, 1)
    case "w": return Coordinate(-2, 0)
    case "sw": return Coordinate(-1, -1)
    case "nw": return Coordinate(-1, 1)
    default: assert(false)
    }
}

private func getAdjacents(from coord: Coordinate) -> [Coordinate] {
    let modifiers = [(2, 0), (1, -1), (1, 1), (-2, 0), (-1, -1), (-1, 1)]
    return modifiers.map({ m in
        Coordinate(coord.x + m.0, coord.y + m.1)
    })
}

private func matches(for regex: String, in text: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

try main()

