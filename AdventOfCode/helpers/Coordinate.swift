struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        "(\(x),\(y))"
    }

    typealias FoldLine = (axis: Axis, location: Int)

    enum Axis: String {
        case y
        case x
    }

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    var adjacents: [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 {
            for y in y-1...y+1  {
                if x == self.x && y == self.y { continue }
                adjacents.append(Coordinate(x, y))
            }
        }
        return adjacents
    }

    func getAdjacentsIncludingSelf() -> [Coordinate] {
        var adjacents: [Coordinate] = []
        for y in y-1...y+1 {
            for x in x-1...x+1 {
                adjacents.append(Coordinate(x, y))
            }
        }

        return adjacents
    }

    // TODO: Don't cast the grid to an [[Any]], use [[T]] instead
    func getAdjacents(in grid: [[Any]], includingSelf: Bool = false) -> [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 where x >= 0 && x < grid[0].count {
            for y in y-1...y+1 where y >= 0 && y < grid.count {
                if x == self.x && y == self.y && !includingSelf { continue }
                adjacents.append(Coordinate(x, y))
            }
        }

        return adjacents
    }

    func getAxialAdjacents() -> [Coordinate] {
        [Coordinate(x-1, y), Coordinate(x+1, y), Coordinate(x, y-1), Coordinate(x, y+1)]
    }

    func getAxialAdjacents<T>(in grid: [[T]]) -> Set<Coordinate> {
        [
            Coordinate(max(0, x-1), y),
            Coordinate(min(grid.count-1, x+1), y),
            Coordinate(x, max(0, y-1)),
            Coordinate(x, min(grid.count-1, y+1))
        ]
    }

    func translate(along foldLine: FoldLine) -> Coordinate {
        let currentValue = foldLine.axis == .y ? y : x
        let difference = (currentValue - foldLine.location) * 2
        let newValue = currentValue - difference

        return Coordinate(foldLine.axis == .y ? x : newValue, foldLine.axis == .y ? newValue : y)
    }

    func getManhattanDistance(to other: Coordinate) -> Int {
        abs(x - other.x) + abs(y - other.y)
    }
}
