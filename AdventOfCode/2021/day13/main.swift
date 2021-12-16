import Foundation

func main() throws {

    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    let coordLines: [String] = input.filter({ !$0.starts(with: "fold") })
    let foldInputLines: [String] = input.filter({ $0.starts(with: "fold") })

    var grid = buildGrid(from: coordLines)
    let foldLines: [Coordinate.FoldLine] = foldInputLines.map({
        let regex = Regex("(y|x)=(\\d+)")
        let matches = regex.getMatches(in: $0)
        return (Coordinate.Axis(rawValue: matches[1])!, Int(matches[2])!)
    })

    grid = foldGrid(grid, along: foldLines[0])
    print("Part 1:", grid.flatMap({ $0 }).filter({ $0 == "#" }).count)
    
    for f in foldLines[1..<foldLines.count] {
        grid = foldGrid(grid, along: f)
    }

    for r in grid {
        print(r.map({String($0)}).joined())
    }
}

private func foldGrid(_ grid: [[Character]], along: Coordinate.FoldLine) -> [[Character]] {
    var grid = grid
    let foldIndex = along.location

    let maxIndex = along.axis == .y ? grid.count : grid[0].count
    let maxAltIndex = along.axis == .y ? grid[0].count : grid.count

    for i in foldIndex+1..<maxIndex {
        for j in 0..<maxAltIndex {
            let yIndex = along.axis == .y ? i : j
            let xIndex = along.axis == .y ? j : i
            // let difference = i - foldIndex

            guard grid[yIndex][xIndex] == "#" else { continue }
            let coordinate = Coordinate(xIndex, yIndex)
            let translated = coordinate.translate(along: along)
            grid[translated.y][translated.x] = "#"
            // let newCoordIndex = i - (difference * 2)

            // if along.axis == "y" {
            //     grid[newCoordIndex][xIndex] = "#"
            // } else {
            //     grid[yIndex][newCoordIndex] = "#"
            // }
        }
    }

    if along.axis == .y {
        grid = Array(grid[0..<foldIndex])
    } else {
        for y in 0..<grid.count {
            grid[y] = Array(grid[y][0..<foldIndex])
        }
    }

    return grid
}

private func buildGrid(from input: [String]) -> [[Character]] {
    var dotCoordinates: Set<Coordinate> = []
    for line in input {
        let split = line.split(separator: ",")
        if split.count == 2 {
            dotCoordinates.insert(Coordinate(Int(split[0])!, Int(split[1])!))
        }
    }

    let maxX = dotCoordinates.max(by: { $0.x < $1.x })!.x
    let maxY = dotCoordinates.max(by: { $0.y < $1.y })!.y

    var grid: [[Character]] = []

    for y in 0...maxY {
        var row: [Character] = []
        for x in 0...maxX {
            let coordinate = Coordinate(x, y)
            row.append(dotCoordinates.contains(coordinate) ? "#" : ".")
        }
        grid.append(row)
    }

    return grid
}

try main()
