import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var grid: [Coordinate: Character] = [:]
    var coords: Set<Coordinate> = []
    var finalDestination: Coordinate!
    var startingPoints: Set<Coordinate> = []
    for rowIndex in 0..<input.count {
        let line = input[rowIndex]
        for colIndex in 0..<line.count {
            let char = line[colIndex]
            let coord = Coordinate(colIndex, rowIndex)
            coords.insert(coord)
            grid[coord] = Character(char)
            if char == "E" { finalDestination = coord }
            if ["a", "S"].contains(char) { startingPoints.insert(coord) }
        }
    }

    let getNeighbours: ((Coordinate) -> Set<Coordinate>) = { coordinate in
        let adjacents = Set(coordinate.getAxialAdjacents())

        let currentLetter = getCurrentLetter(grid: grid, coord: coordinate)!
        let result = adjacents.filter({
            guard let char = getCurrentLetter(grid: grid, coord: $0) else { return false }
            return char.asciiValue! <= currentLetter.asciiValue! + 1
        })
        return result
    }

    let part1Start = startingPoints.first(where: { grid[$0] == "S" })!
    let part1 = bfs(graph: coords, source: part1Start, target: finalDestination, getNeighbours: getNeighbours, getDistanceBetween: { _, _ in 1})
    print(part1.distances[finalDestination]!)
    let part2 = bfs(graph: coords, source: startingPoints, target: finalDestination, getNeighbours: getNeighbours, getDistanceBetween: { _, _ in 1})
    print(part2.distances[finalDestination]!)

    let visited = getVisited(from: part1.prev, end: finalDestination)
    printPath(grid: grid, visited: visited)
}

private func getCurrentLetter(grid: [Coordinate: Character], coord: Coordinate) -> Character? {
    let char = grid[coord]
    return [
        "S": "a",
        "E": "z"
    ][char] ?? char
}

private func getVisited(from prev: [Coordinate: Coordinate], end: Coordinate) -> Set<Coordinate> {
    var visited = Set<Coordinate>()
    visited.insert(end)
    var current = prev[end]
    while current != nil {
        visited.insert(current!)
        current = prev[current!]
    }

    return visited
}

private func printPath(grid: [Coordinate: Character], visited: Set<Coordinate>) {
    let maxX = grid.keys.map({$0.x}).max()!
    let maxY = grid.keys.map({$0.y}).max()!
    for y in 0...maxY {
        print((0...maxX).map({
            let coordinate = Coordinate($0, y)
            return visited.contains(coordinate) ? String(grid[coordinate]!) : "."
        }).joined())
    }
}

Timer.time(main)
