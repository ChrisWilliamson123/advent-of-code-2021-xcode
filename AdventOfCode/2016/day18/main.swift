import Foundation

func main() throws {
    let input = "^.^^^.^..^....^^....^^^^.^^.^...^^.^.^^.^^.^^..^.^...^.^..^.^^.^..^.....^^^.^.^^^..^^...^^^...^...^."
    var traps: Set<Coordinate> = input.enumerated().reduce(into: [], { if $1.element == "^" { $0.insert(Coordinate($1.offset, 0)) } })
    let maxX = input.count
    let rows = 400000
    for y in 1..<rows {
        let previousRow = (-1...maxX).map { traps.contains(Coordinate($0, y-1)) }
        for x in 0..<maxX {
            let cur = Coordinate(x, y)
            let previousThree = [previousRow[x], previousRow[x+1], previousRow[x+2]]
            if previousThree == [true, true, false] {
                traps.insert(cur)
            } else if previousThree == [false, true, true] {
                traps.insert(cur)
            } else if previousThree == [true, false, false] {
                traps.insert(cur)
            } else if previousThree == [false, false, true] {
                traps.insert(cur)
            }
        }
    }
    print((rows*maxX) - traps.count)
}

Timer.time(main)
