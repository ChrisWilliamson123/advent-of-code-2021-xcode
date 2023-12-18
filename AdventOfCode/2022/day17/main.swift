import Foundation

enum GasJet: String {
    case left = "<"
    case right = ">"

    var movement: Coordinate {
        switch self {
        case .left:
            return .init(-1, 0)
        case .right:
            return .init(1, 0)
        }
    }
}

struct Rock: Hashable {
    let shape: Set<Coordinate>
    let origin: Coordinate
    let coords: Set<Coordinate>

    init(shape: Set<Coordinate>, origin: Coordinate) {
        self.shape = shape
        self.origin = origin
        self.coords = shape.reduce(into: Set<Coordinate>(), { $0.insert(origin + $1) })
    }
}

struct Slice: Hashable {
    let rocks: Set<Rock>
    let origin: Coordinate

    func hash(into hasher: inout Hasher) {
        hasher.combine(rocks)
    }
}

class Cave {
    private let gasJets: [GasJet]
    private let rockShapes: [Set<Coordinate>] = [
        [.init(0, 0), .init(1, 0), .init(2, 0), .init(3, 0)],
        [.init(1, 0), .init(0, -1), .init(1, -1), .init(2, -1), .init(1, -2)],
        [.init(2, 0), .init(2, -1), .init(0, -2), .init(1, -2), .init(2, -2)],
        [.init(0, 0), .init(0, -1), .init(0, -2), .init(0, -3)],
        [.init(0, 0), .init(1, 0), .init(0, -1), .init(1, -1)]
    ]
    private var rocksFallen = 0
    private var fallenRocks: [Rock] = []
    private var currentlyFallingRock: Rock
    private var attemptedJetMovements = 0
    private var lastTwenty: [Rock] = [] {
        didSet {
            cacheCheck = true
        }
    }
    private var rockCoords: Set<Coordinate> = []
    private var cacheCheck = false

    init(gasJets: [GasJet]) {
        self.gasJets = gasJets

        self.currentlyFallingRock = Rock(shape: rockShapes[0], origin: Coordinate(2, 3))
        fallenRocks.reserveCapacity(1000000)
//        printCave()
    }

    struct CacheItem: Hashable {
        let grid: [[Character]]
//        let rocksFallen: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(grid)
        }
    }

    func simulateRocks() {
        /*
         On each tick, use a jet to try and move the rock, then try to move the rock down
         */
//        seen =
        var grids: Set<CacheItem> = []
        while 1 == 1 {
//            if rocksFallen %  == 0 { print (rocksFallen) }
//            print(rocksFallen)
            // Get the last twenty to get maxY
            if cacheCheck, let maxY = lastTwenty.last?.origin.y {
                // build a grid of last twenty
                var grid = [[Character]]()
                for y in stride(from: maxY, to: maxY-40, by: -1) {
                    var gridRow: [Character] = []
                    for x in 0..<7 {
                        let coord = Coordinate(x, y)
                        if rockCoords.contains(coord) {
                            gridRow.append("#")
                        } else {
                            gridRow.append(".")
                        }
                    }
                    grid.append(gridRow)
                }
                let item = CacheItem(grid: grid)
                cacheCheck = false
                if grids.contains(item) {
                    print("Found pattern")
                    print("TopOfFallen:", lastTwenty.last!.origin.y)
                    print("Number of fallen:", rocksFallen)
                    if 1000000000000 % rocksFallen == 0 {
                        print("HERE!")
                        break
                    }
                    grids.removeAll()
                    grids.insert(item)
//                    break
                } else {
                    grids.insert(item)
                }
            }
            let jet = gasJets[attemptedJetMovements % gasJets.count]
            if jetCanMoveRock(jet) {
                currentlyFallingRock = Rock(shape: currentlyFallingRock.shape, origin: currentlyFallingRock.origin + jet.movement)
//                printCave()
            }
            attemptedJetMovements += 1

            // Now try to move it down
            if canMoveRockDown() {
                currentlyFallingRock = Rock(shape: currentlyFallingRock.shape, origin: currentlyFallingRock.origin + Coordinate(0, -1))
//                printCave()
            } else {
                // we can't move rock down, so it must settle and spawn new rock
                fallenRocks.append(currentlyFallingRock)
                lastTwenty.append(currentlyFallingRock)
                currentlyFallingRock.coords.forEach({ rockCoords.insert($0) })
                rocksFallen += 1
                if rocksFallen > 20 {
                    lastTwenty.removeFirst()
                }
                lastTwenty = lastTwenty.sorted(by: { $0.origin.y < $1.origin.y })
//                if rocksFallen > 20 {
//                } else {
//                    fallenRocks = fallenRocks.sorted(by: { $0.origin.y < $1.origin.y })
//                }
//                printCave()
                spawnNewRock()
//                printCave()
            }
        }
        let maxY = lastTwenty.last!.origin.y
        print(maxY + 1)
//        printCave()
    }

    private func jetCanMoveRock(_ jet: GasJet) -> Bool {
        let currentRockPositions = currentlyFallingRock.coords
        let postMoveCoords = currentRockPositions.map { $0 + jet.movement }
        // If new positions are out of x bounds, return false
        let xBounds = 0..<7
        for c in postMoveCoords where !xBounds.contains(c.x) {
            return false
        }
        // If new positions collide with existing fallen rock, return false
        for rock in lastTwenty {
            for c in rock.coords where postMoveCoords.contains(c) {
                return false
            }
        }
        return true
    }

    private func canMoveRockDown() -> Bool {
        let currentRockPositions = currentlyFallingRock.coords
        let postMoveCoords = currentRockPositions.map { $0 + Coordinate(0, -1) }
        if postMoveCoords.contains(where: { $0.y < 0 }) {
            return false
        }
        // If new positions collide with existing fallen rock, return false
        for rock in lastTwenty {
            for c in rock.coords where postMoveCoords.contains(c) {
                return false
            }
        }
        return true
    }

    private func spawnNewRock() {
        let newShape = rockShapes[rocksFallen % rockShapes.count]
        let maxY = lastTwenty.last!.origin.y
        let newCoordY = maxY + 4 + newShape.map { abs($0.y) }.max()!
        currentlyFallingRock = Rock(shape: newShape, origin: Coordinate(2, newCoordY))
    }

    func printCave() {
        print("\n")
        let maxy = currentlyFallingRock.origin.y
        let fallenRockCoords = fallenRocks.reduce(into: Set<Coordinate>(), { $0 = $0.union($1.coords) })
        for y in stride(from: maxy, through: 0, by: -1) {
            var toPrint = ""
            for x in 0..<7 {
                let coord = Coordinate(x, y)
                let currentRockCoords = currentlyFallingRock.coords
                if currentRockCoords.contains(coord) {
                    toPrint += "@"
                    continue
                }

                if fallenRockCoords.contains(coord) {
                    toPrint += "#"
                } else {
                    toPrint += "."
                }
            }
            print(toPrint)
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let gasJets = input[0].compactMap { GasJet.init(rawValue: String($0)) }

    let cave = Cave(gasJets: gasJets)
    cave.simulateRocks()
}

Timer.time(main)
