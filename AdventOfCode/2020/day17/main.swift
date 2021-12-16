import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var activeCubes: Set<Coord3D> = []

    for y in 0..<input.count {
        for x in 0..<input[y].count {
            let coord = Coord3D(x, y, 0, 0)
            if input[y][x] == "#" { activeCubes.insert(coord) }
        }
    }

    let cycles = 6

    var adjacentsMap: [Coord3D: Set<Coord3D>] = [:]

    for _ in 0..<cycles {
        var state = activeCubes
        let boundsToConsider = getBoundsToConsider(activeCubes: activeCubes)
        for x in boundsToConsider.x {
            for y in boundsToConsider.y {
                for z in boundsToConsider.z {
                    for w in boundsToConsider.w {
                        let coord = Coord3D(x, y, z, w)
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
                }
            }
        }

        activeCubes = state
    }
}

try main()

struct Coord3D: Hashable {
    let x: Int
    let y: Int
    let z: Int
    let w: Int

    var adjacents: Set<Coord3D> {
        var adjacents: Set<Coord3D> = []
        for x in x-1...x+1 {
            for y in y-1...y+1 {
                for z in z-1...z+1 {
                    for w in w-1...w+1 {
                        if x == self.x && y == self.y && z == self.z && w == self.w { continue }
                        adjacents.insert(.init(x, y, z, w))
                    }
                }
            }
        }

        return adjacents
    }

    init(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

//struct Coord4D: Hashable {
//    let x: Int
//    let y: Int
//    let z: Int
//
//    var adjacents: Set<Coord3D> {
//        var adjacents: Set<Coord3D> = []
//        for x in x-1...x+1 {
//            for y in y-1...y+1 {
//                for z in z-1...z+1 {
//                    if x == self.x && y == self.y && z == self.z { continue }
//                    adjacents.insert(.init(x, y, z))
//                }
//            }
//        }
//
//        return adjacents
//    }
//
//    init(_ x: Int, _ y: Int, _ z: Int) {
//        self.x = x
//        self.y = y
//        self.z = z
//    }
//}

private func getBoundsToConsider(activeCubes: Set<Coord3D>) -> (x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>, w: ClosedRange<Int>) {
    var xMin = Int.max
    var xMax = Int.min

    var yMin = Int.max
    var yMax = Int.min

    var zMin = Int.max
    var zMax = Int.min

    var wMin = Int.max
    var wMax = Int.min

    for c in activeCubes {
        xMin = min(xMin, c.x)
        xMax = max(xMax, c.x)

        yMin = min(yMin, c.y)
        yMax = max(yMax, c.y)

        zMin = min(zMin, c.z)
        zMax = max(zMax, c.z)

        wMin = min(wMin, c.w)
        wMax = max(wMax, c.w)
    }

    return (xMin-1...xMax+1, yMin-1...yMax+1, zMin-1...zMax+1, wMin-1...wMax+1)
}

