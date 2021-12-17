import Foundation

func main() throws {
    let input: String = try readInput(fromTestFile: false)[0]
    let regex = Regex("(-?\\d+)..(-?\\d+), y=(-?\\d+)..(-?\\d+)")
    let matches = regex.getMatches(in: input).suffix(from: 1).map({ String($0) })
    let xTargetRange = Int(matches[0])!...Int(matches[1])!
    let yTargetRange = Int(matches[2])!...Int(matches[3])!

    func getShotYRange(_ velocity: Int) -> Set<Int> {
        let ticks = 1000
        var velocity = velocity
        var latest = velocity
        var positions: Set<Int> = [latest]
        for _ in 0..<ticks {
            velocity -= 1
            latest += velocity
            positions.insert(latest)
        }
        return positions
    }

    let yPositionsHit = getShotYRange(abs(yTargetRange.lowerBound) - 1)
    print("Part 1:", yPositionsHit.max()!)

    func getXNeeded(_ bound: Int) -> Int {
        let xDiff = bound - 0
        var tracker = 0
        var step = 0
        var steps = -1
        while tracker < xDiff {
            tracker += step
            step += 1
            steps += 1
        }
        return steps
    }

    let xRange = getXNeeded(xTargetRange.lowerBound)...xTargetRange.upperBound
    let yRange = yTargetRange.lowerBound...(abs(yTargetRange.lowerBound) - 1)
    var valids: Set<Coordinate> = []
    for x in xRange {
        for y in yRange {
            var position = Coordinate(0, 0)
            let initialV = Coordinate(x, y)
            var velocity = initialV
            var ticks = 0
            while (!xTargetRange.contains(position.x) || !yTargetRange.contains(position.y)) && ticks < 500 {
                position = Coordinate(position.x + velocity.x, position.y + velocity.y)

                let xVel: Int
                if velocity.x > 0 {
                    xVel = velocity.x - 1
                } else if velocity.x < 0 {
                    xVel = velocity.x + 1
                } else {
                    xVel = 0
                }

                let yVel = velocity.y - 1

                velocity = Coordinate(xVel, yVel)
                ticks += 1
            }
            if ticks > 499 {
                continue
            }
            valids.insert(initialV)
        }
    }

    print("Part 2:", valids.count)

}

try main()

