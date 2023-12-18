import Foundation

func main(dimensions: Int, cycles: Int, part: Int, usingTestInput: Bool = false) throws {
    let input: [String] = try readInput(fromTestFile: usingTestInput)

    var activeCubes: Set<MultiDimensionalCoord> = []

    for y in 0..<input.count {
        for x in 0..<input[y].count {
            var coordComponents: [Int] = Array(repeating: 0, count: dimensions)
            coordComponents[0] = x
            coordComponents[1] = y
            let coord = MultiDimensionalCoord(coordComponents)
            if input[y][x] == "#" { activeCubes.insert(coord) }
        }
    }

    var adjacentsMap: [MultiDimensionalCoord: Set<MultiDimensionalCoord>] = [:]

    for _ in 0..<cycles {
        var state = activeCubes
        let allCoordsToConsider: Set<MultiDimensionalCoord> = getAllCoordsToConsider(dimensions: dimensions, activeCubes: activeCubes)

        for coord in allCoordsToConsider {
            let coordIsActive = activeCubes.contains(coord)

            let adjacents = adjacentsMap[coord] ?? coord.adjacents
            adjacentsMap[coord] = adjacents

            let numberOfActiveAdjacents = adjacents.reduce(0, { activeCubes.contains($1) ? $0 + 1 : $0 })

            if coordIsActive {
                if !(numberOfActiveAdjacents == 2 || numberOfActiveAdjacents == 3) {
                    state.remove(coord)
                }
            } else {
                if numberOfActiveAdjacents == 3 {
                    state.insert(coord)
                }
            }
        }

        activeCubes = state
    }
    print("Part \(part):", activeCubes.count)
}

struct MultiDimensionalCoord: Hashable {
    let components: [Int]

    var adjacents: Set<MultiDimensionalCoord> {
        let adjacents = getAdjacents()
        var asSet = Set(adjacents.map({ MultiDimensionalCoord($0) }))
        asSet.remove(self)
        return asSet
    }

    private func getAdjacents(forComponents: [Int]? = nil) -> [[Int]] {
        if forComponents == nil {
            return getAdjacents(forComponents: self.components)
        }

        if forComponents!.count == 1 {
            let toChange = forComponents![0]
            return [[toChange-1], [toChange], [toChange+1]]
        }

        var results: [[Int]] = []
        var mutable = forComponents!
        let last = mutable.popLast()!
        let prev = getAdjacents(forComponents: mutable)
        for i in last-1...last+1 {
            for p in prev {
                results.append(p + [i])
            }
        }

        return results
    }

    init(_ components: [Int]) {
        self.components = components
    }
}

private func getAllCoordsToConsider(dimensions: Int, activeCubes: Set<MultiDimensionalCoord>) -> Set<MultiDimensionalCoord> {
    let bounds = (0..<dimensions).map({ getBoundsToConsider(for: $0, activeCubes: activeCubes) })

    func work(forComponents: [ClosedRange<Int>]) -> [[Int]] {
        if forComponents.count == 1 {
            return forComponents[0].map({ [$0] })
        }

        var results: [[Int]] = []
        var mutable = forComponents
        let last = mutable.popLast()!
        let prev = work(forComponents: mutable)
        for i in last {
            for p in prev {
                results.append(p + [i])
            }
        }

        return results

    }

    return Set(work(forComponents: bounds).map({ MultiDimensionalCoord($0) }))
}

private func getBoundsToConsider(for componentIndex: Int, activeCubes: Set<MultiDimensionalCoord>) -> ClosedRange<Int> {
    var minC = Int.max
    var maxC = Int.min

    for c in activeCubes {
        minC = min(minC, c.components[componentIndex])
        maxC = max(maxC, c.components[componentIndex])
    }

    return (minC-1...maxC+1)
}

try main(dimensions: 3, cycles: 6, part: 1)
try main(dimensions: 4, cycles: 6, part: 2)
