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

    /// Normalises a coordinate to contain either -1, 0 or 1 for x and y values
    var normalised: Coordinate {
        let getNormalisedValue: ((Int) -> Int) = { $0 == 0 ? 0 : $0 / abs($0) }
        return Coordinate(getNormalisedValue(x), getNormalisedValue(y))
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

    /**
     Gets the adjacent coordinates that exist within the bounds of the provided grid.
     Can include the current coodinate if desired.
     */
    func getAdjacents<T>(in grid: [[T]], includingSelf: Bool = false) -> [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 where x >= 0 && x < grid[0].count {
            for y in y-1...y+1 where y >= 0 && y < grid.count {
                if x == self.x && y == self.y && !includingSelf { continue }
                adjacents.append(Coordinate(x, y))
            }
        }

        return adjacents
    }

    /**
     Gets the adjacent coordinates that exist within the provided closed range bounds.
     Can include the current coodinate if desired.
     */
    func getAdjacents(xBounds: ClosedRange<Int>, yBounds: ClosedRange<Int>, includingSelf: Bool = false) -> [Coordinate] {
        var adjacents: [Coordinate] = []
        for x in x-1...x+1 where x >= xBounds.lowerBound && x <= xBounds.upperBound {
            for y in y-1...y+1 where y >= yBounds.lowerBound && y <= yBounds.upperBound {
                if x == self.x && y == self.y && !includingSelf { continue }
                adjacents.append(Coordinate(x, y))
            }
        }

        return adjacents
    }

    /**
     Gets the four axial adjacent coordinates
     */
    func getAxialAdjacents() -> [Coordinate] {
        [Coordinate(x-1, y), Coordinate(x+1, y), Coordinate(x, y-1), Coordinate(x, y+1)]
    }

    /**
     Gets the four axial adjacent coordinates that exist within the bounds of the provided grid. Can include self if self is on a bound line.
     */
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

    static func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        Coordinate(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func +=(lhs: inout Coordinate, rhs: Coordinate) {
        lhs = Coordinate(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func -(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        Coordinate(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    func getLineTo(_ other: Coordinate, includeEnds: Bool = true) -> Set<Coordinate>? {
        let diff = other - self
        if self.x != other.x && self.y != other.y && abs(diff.x) != abs(diff.y) { return nil }

        let normalised = diff.normalised
        var line = [Coordinate]()
        line.append(self)

        for _ in 0..<max(abs(diff.x), abs(diff.y)) {
            let prev = line.last!
            line.append(prev + normalised)
        }

        if !includeEnds {
            line.remove(at: 0)
        } else {
            line.append(other)
        }
        return Set(line)
    }

    func getCoordsWithinDistance(_ distance: Int) -> Set<Coordinate> {
        let minY = y - distance
        let maxY = y + distance
        let minX = x - distance
        let maxX = x + distance
        var set = Set<Coordinate>()
        for y in minY...maxY {
            for x in minX...maxX {
                let position = Coordinate(x, y)
                if getManhattanDistance(to: position) <= distance {
                    set.insert(position)
                }
            }
        }
        print("Got coords within distance")
        return set
    }
}
