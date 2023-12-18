func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let grid = input.map { line in line.map { Int($0)! } }

    var visible = 0
    var maxScenicScore = 0
    for y in 1..<(grid.count-1) {
        for x in 1..<(grid.count-1) {
            let value = grid[y][x]
            let previousY: [Int] = (0..<y).map({ grid[$0][x] }).reversed()
            let nextY = (y+1..<grid.count).map { grid[$0][x] }
            let previousX: [Int] = (0..<x).map({ grid[y][$0] }).reversed()
            let nextX = (x+1..<grid.count).map { grid[y][$0] }
            let allDirections = [previousY, previousX, nextY, nextX]

            if allDirections.first(where: { value > $0.max() ?? 0 }) != nil {
                visible += 1
                let scenicScore = allDirections.map({ viewingDistance(value, blockers: $0) }).multiply()
                maxScenicScore = max(maxScenicScore, scenicScore)
            }
        }
    }

    let outsideTrees = ((grid.count - 2) * 4) + 4
    print(visible + outsideTrees)
    print(maxScenicScore)
}

private func viewingDistance(_ tree: Int, blockers: [Int]) -> Int {
    guard let firstBlockerIndex = blockers.firstIndex(where: { $0 >= tree }) else {
        return blockers.count
    }
    return firstBlockerIndex + 1
}

Timer.time(main)
