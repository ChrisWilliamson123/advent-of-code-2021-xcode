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

Timer.time(main)
