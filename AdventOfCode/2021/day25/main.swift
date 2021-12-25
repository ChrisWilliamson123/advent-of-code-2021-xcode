import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var rights: Set<Coordinate> = []
    var downs: Set<Coordinate> = []
    let maxX: Int = input[0].count
    let maxY: Int = input.count

    for y in 0..<input.count {
        for x in 0..<input[y].count {
            let char: Character = input[y][x]
            if char == ">" { rights.insert(Coordinate(x, y))}
            else if char == "v" { downs.insert(Coordinate(x, y))}
        }
    }
//    var grid = input.map({ [Character]($0) })
//    printGrid(rights: rights, downs: downs, maxX: maxX, maxY: maxY)

    var step = 0
    while true {
        step += 1
        let new = tick(rights: rights, downs: downs, maxX: maxX, maxY: maxY)
        if new.rights == rights && new.downs == downs {

            print("Complete, \(step)")
            assert(false)
        }
//        print(new.rights)
//        print(new.downs)
        rights = new.rights
        downs = new.downs
//        printGrid(rights: rights, downs: downs, maxX: maxX, maxY: maxY)
//        assert(false)
    }
}

private func tick(rights: Set<Coordinate>, downs: Set<Coordinate>, maxX: Int, maxY: Int) -> (rights: Set<Coordinate>, downs: Set<Coordinate>) {
    let newRights = step(rights, against: downs, char: ">", maxX: maxX, maxY: maxY)
    let newDowns = step(downs, against: newRights, char: "v", maxX: maxX, maxY: maxY)

    return (newRights, newDowns)
}

private func step(_ coords: Set<Coordinate>, against: Set<Coordinate>, char: Character, maxX: Int, maxY: Int) -> Set<Coordinate> {
    var newSet: Set<Coordinate> = coords

    for c in coords {
        let direction = getDirection(for: char)
        let nextX = (c.x + direction.x) % maxX
        let nextY = (c.y + direction.y) % maxY
        let nextC = Coordinate(nextX, nextY)
        if !coords.contains(nextC) && !against.contains(nextC) {
            newSet.insert(nextC)
            newSet.remove(c)
        }
    }

    return newSet
}

private func printGrid(rights: Set<Coordinate>, downs: Set<Coordinate>, maxX: Int, maxY: Int) {
    print("\n")
    for y in 0..<maxY {
        var toPrint = ""
        for x in 0..<maxX {
            let c = Coordinate(x, y)
            if rights.contains(c) { toPrint += ">" }
            else if downs.contains(c) { toPrint += "v" }
            else { toPrint += "." }
        }
        print(toPrint)
    }
}

private func getNextCoordinate(for char: Character, at coordinate: Coordinate, in grid: [[Character]]) -> Coordinate? {
    let direction = getDirection(for: char)
    let nextX = (coordinate.x + direction.x) % grid[0].count
    let nextY = (coordinate.y + direction.y) % grid.count
    if grid[nextY][nextX] == "." {
        return Coordinate(nextX, nextY)
    }
    return nil
}

private func getDirection(for char: Character) -> Coordinate {
    [
        ">": Coordinate(1, 0),
        "v": Coordinate(0, 1)
    ][char]!
}

try main()

