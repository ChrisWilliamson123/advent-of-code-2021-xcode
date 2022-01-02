import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let grid = input.map({ [Character]($0) })
    var onLights: Set<Coordinate> = []
    for y in 0..<input.count {
        for x in 0..<input[0].count {
            if grid[y][x] == "#" {

                let coord = Coordinate(x, y)
                onLights.insert(coord)
            }
        }
    }
    onLights.insert(Coordinate(0, 99))
    onLights.insert(Coordinate(99, 0))
    onLights.insert(Coordinate(0, 0))
    onLights.insert(Coordinate(99, 99))

    for _ in 0..<100 {
        onLights = tick(lights: onLights)
    }

    onLights.insert(Coordinate(0, 99))
    onLights.insert(Coordinate(99, 0))
    onLights.insert(Coordinate(0, 0))
    onLights.insert(Coordinate(99, 99))

    print(onLights.count)
}

private func tick(lights: Set<Coordinate>) -> Set<Coordinate> {
    var new: Set<Coordinate> = []
    for y in 0..<100 {
        for x in 0..<100 {
            let coord = Coordinate(x, y)
            let adjacents = coord.getAdjacents(xBounds: 0...99, yBounds: 0...99)
            let isOn = lights.contains(coord)
            let onAdjacents = adjacents.filter({ lights.contains($0) })
            if isOn && [2, 3].contains(onAdjacents.count) {
                new.insert(coord)
            } else if !isOn && onAdjacents.count == 3 {
                new.insert(coord)
            }
        }
    }
    new.insert(Coordinate(0, 99))
    new.insert(Coordinate(99, 0))
    new.insert(Coordinate(0, 0))
    new.insert(Coordinate(99, 99))
    return new
}

try main()
