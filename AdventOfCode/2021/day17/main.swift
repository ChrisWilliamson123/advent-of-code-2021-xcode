import Foundation

func main() throws {
    let input: String = try readInput(fromTestFile: false)[0]
    let regex = Regex("(-?\\d+)..(-?\\d+), y=(-?\\d+)..(-?\\d+)")
    let matches = regex.getMatches(in: input).suffix(from: 1).map({ String($0) })
    let xTargetRange = Int(matches[0])!...Int(matches[1])!
    let yTargetRange = Int(matches[2])!...Int(matches[3])!

    let yRange = yTargetRange.lowerBound...(abs(yTargetRange.lowerBound) - 1)

    // LHS of this range is solving quadratic to get smallest velocity needed to reach target
    let xRange = Int(round((sqrt(Double(2 * xTargetRange.lowerBound)) - 1) / 2))...xTargetRange.upperBound

    var valids: Set<Coordinate> = []
    var maxY = Int.min
    for x in xRange {
        for y in yRange {
            var position = Coordinate(0, 0)
            let initialV = Coordinate(x, y)
            var velocity = initialV
            var ticks = 0
            while (!xTargetRange.contains(position.x) || !yTargetRange.contains(position.y)) && ticks < 500 {
                position = Coordinate(position.x + velocity.x, position.y + velocity.y)

                var xVel = velocity.x
                if velocity.x > 0 { xVel -= 1 }
                else if velocity.x < 0 { xVel += 1 }

                velocity = Coordinate(xVel, velocity.y - 1)
                ticks += 1
                maxY = max(maxY, position.y)
            }
            if ticks > 499 {
                continue
            }
            valids.insert(initialV)
        }
    }
    print("Part 1:", maxY)
    print("Part 2:", valids.count)
}

Timer.time(main)

