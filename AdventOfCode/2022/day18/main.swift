import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let cubes: Set<[Int]> = Set(input.map({ $0.components(separatedBy: ",").map({ Int($0)! }) }))

    /**
     For part one, loop through all cubes and get their adjacent cubes.
     If an adjacent cube is not a lava cube, then add it to the dict with a value of one.
     If it already exists in the dict, add one to it
     The dict represents the number of solid neighbours that an air block has
     After building the dict, add up all of the value to get the number of lava cube sides that touch air
     */
    var numberOfCubeNeighboursPerAir: [[Int]: Int] = [:]
    for cube in cubes {
        let adjacents = getAdjacents(cube)
        for a in adjacents.filter({ !cubes.contains($0) }) {
            numberOfCubeNeighboursPerAir[a] = (numberOfCubeNeighboursPerAir[a] ?? 0) + 1
        }
    }
    print(numberOfCubeNeighboursPerAir.values.reduce(0, +))

    /**
     For part two, use DFS to get a set of cubes that are visitable. A cube is visitable if there is a path to it that is not blocked by a lava block.
     Next, tot up the values from part one where the air block is in the visitable set.
     */
    let maxDimension = cubes.flatMap({ $0 }).max()!
    let minDimension = cubes.flatMap({ $0 }).min()!

    var queue = [[0,0,0]]
    var visited: Set<[Int]> = []
    while !queue.isEmpty {
        var current = queue.popLast()!
        visited.insert(current)
        for adjacent in getAdjacents(current) {
            if visited.contains(adjacent) { continue }
            if adjacent.min()! < minDimension - 2 || adjacent.max()! > maxDimension + 2 { continue }
            if cubes.contains(adjacent) { continue }
            queue.append(adjacent)
        }
    }

    print(numberOfCubeNeighboursPerAir.filter({ visited.contains($0.key) }).values.reduce(0, +))
}

private func getAdjacents(_ cube: [Int]) -> [[Int]] {
    [
        [0 + cube[0], 0 + cube[1], 1 + cube[2]],
        [0 + cube[0], 0 + cube[1], -1 + cube[2]],

        [0 + cube[0], 1 + cube[1], 0 + cube[2]],
        [0 + cube[0], -1 + cube[1], 0 + cube[2]],

        [1 + cube[0], 0 + cube[1], 0 + cube[2]],
        [-1 + cube[0], 0 + cube[1], 0 + cube[2]],
    ]
}

//func main() throws {
//    let input: [String] = try readInput(fromTestFile: false)
//    let cubes: [[Int]] = input.map { $0.components(separatedBy: ",").map({ Int($0)! }) }
//    var exposed = 0
//    var airs: [[Int]] = []
//    for i in cubes {
//        // make a list of adjacent coords
//        let adjacents =
//            [
//                [0 + i[0], 0 + i[1], 1 + i[2]],
//                [0 + i[0], 0 + i[1], -1 + i[2]],
//
//                [0 + i[0], 1 + i[1], 0 + i[2]],
//                [0 + i[0], -1 + i[1], 0 + i[2]],
//
//                [1 + i[0], 0 + i[1], 0 + i[2]],
//                [-1 + i[0], 0 + i[1], 0 + i[2]],
//            ]
//        airs.append(contentsOf: adjacents.filter({ !cubes.contains($0) }))
//        let neighbours = adjacents.filter({ cubes.contains($0) })
//        exposed += 6 - neighbours.count
//    }
//    var cantGetTo = 0
//    var all: [[Int]] = []
//    for x in -2...22 {
//        for y in -2...22 {
//            for z in -2...22 {
//                all.append([x, y, z])
//            }
//        }
//    }
//    var allNeighbours: [[Int]: [[Int]]] = [:]
//    for j in all {
//        let adjacents =
//        [
//            [0 + j[0], 0 + j[1], 1 + j[2]],
//            [0 + j[0], 0 + j[1], -1 + j[2]],
//
//            [0 + j[0], 1 + j[1], 0 + j[2]],
//            [0 + j[0], -1 + j[1], 0 + j[2]],
//
//            [1 + j[0], 0 + j[1], 0 + j[2]],
//            [-1 + j[0], 0 + j[1], 0 + j[2]],
//        ]
//        let neighbours = adjacents.filter({ !cubes.contains($0) && (-2..<22).contains($0[0]) && (-2..<22).contains($0[1]) && (-2..<22).contains($0[2]) })
//        allNeighbours[j] = neighbours
//    }
//    var canGetTo: [[Int]] = []
//    for i in Set(airs.filter({ (-2..<22).contains($0[0]) && (-2..<22).contains($0[1]) && (-2..<22).contains($0[2]) })) {
//        let result = aStar(graph: Set(all), source: i, target: [0,0,0], getNeighbours: {
////            print($0)
//            return Set(allNeighbours[$0]!)
//
//        }, getDistanceBetween: { _, _ in
//            1
//        }, heuristicFunction: { current, target in
//            abs(current[0] - target[0]) + abs(current[1] - target[1]) + abs(current[2] - target[2])
//        })
//        if result.distances[[0,0,0]]! < Int.max {
//            canGetTo.append(i)
//        }
//    }
//    print(exposed)
//    print(canGetTo.count)
//    var sa = 0
//    for j in canGetTo {
//        let adjacents =
//        [
//            [0 + j[0], 0 + j[1], 1 + j[2]],
//            [0 + j[0], 0 + j[1], -1 + j[2]],
//
//            [0 + j[0], 1 + j[1], 0 + j[2]],
//            [0 + j[0], -1 + j[1], 0 + j[2]],
//
//            [1 + j[0], 0 + j[1], 0 + j[2]],
//            [-1 + j[0], 0 + j[1], 0 + j[2]],
//        ]
//        let cubeneighbours = adjacents.filter { cubes.contains($0) }
//
//        sa += cubeneighbours.count
//    }
//    print(sa)
////    print(fullyTrapped.count)
//
//    // 1973 too low
//}

Timer.time(main)
