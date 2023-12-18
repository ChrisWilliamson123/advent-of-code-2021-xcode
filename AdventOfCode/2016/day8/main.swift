import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var screen = Screen()
    input.forEach({ screen.executeInstruction($0) })
    print("Part one:", screen.litPixelsCount)
    screen.print()
}

struct Screen {
    var pixels: [[Bool]] = Array(repeating: Array(repeating: false, count: 50), count: 6)

    private var litPixels: Set<Coordinate> {
        var lit = Set<Coordinate>()
        for y in 0..<pixels.count {
            for x in 0..<pixels[0].count where pixels[y][x] {
                lit.insert(Coordinate(x, y))
            }
        }

        return lit
    }
    var litPixelsCount: Int { litPixels.count }

    mutating func executeInstruction(_ instruction: String) {
        let split = instruction.split(separator: " ")
        switch (split[0], split[1]) {
        case ("rect", _): turnOn(x: Int(split[1].split(separator: "x").first!)!, y: Int(split[1].split(separator: "x").last!)!)
        case ("rotate", "row"): rotateRow(Int(split[2].last!)!, by: Int(split.last!)!)
        case ("rotate", "column"): rotateColumn(Int(split[2].split(separator: "=").last!)!, by: Int(split.last!)!)
        default: assert(false, "Unexpected instruction")
        }
    }

    mutating private func turnOn(x: Int, y: Int) {
        for yIndex in 0..<y {
            for xIndex in 0..<x {
                pixels[yIndex][xIndex] = true
            }
        }
    }

    mutating private func rotateRow(_ rowIndex: Int, by amount: Int) {
        pixels[rowIndex].rotateRight(positions: amount)
    }

    mutating private func rotateColumn(_ columnIndex: Int, by amount: Int) {
        let column = (0..<pixels.count).map({ pixels[$0][columnIndex] })
        let rotated = Array(column.rotatingRight(positions: amount))
        (0..<pixels.count).forEach({ pixels[$0][columnIndex] = rotated[$0] })
    }

    func print() {
        for y in 0..<pixels.count {
            var row = ""
            for x in 0..<pixels[0].count {
                row.append(pixels[y][x] == true ? "#" : ".")
            }
            Swift.print(row)
        }
    }
}

Timer.time(main)
