import Foundation
import simd

extension ClosedRange {
    public func intersect(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let lowerBoundMax = Swift.max(self.lowerBound, other.lowerBound)
        let upperBoundMin = Swift.min(self.upperBound, other.upperBound)

        let lowerBeforeUpper = lowerBoundMax <= self.upperBound && lowerBoundMax <= other.upperBound
        let upperBeforeLower = upperBoundMin >= self.lowerBound && upperBoundMin >= other.lowerBound

        if lowerBeforeUpper && upperBeforeLower {
            return lowerBoundMax...upperBoundMin
        }

        return nil
    }
}

struct Cuboid: Hashable {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let zRange: ClosedRange<Int>

    var volume: Int { (xRange.count) * (yRange.count) * (zRange.count) }

    func getIntersectingCuboid(with cuboid2: Cuboid) -> Cuboid? {
        let xRangeIntersection = self.xRange.intersect(cuboid2.xRange)
        let yRangeIntersection = self.yRange.intersect(cuboid2.yRange)
        let zRangeIntersection = self.zRange.intersect(cuboid2.zRange)

        if let xRangeIntersection = xRangeIntersection, let yRangeIntersection = yRangeIntersection, let zRangeIntersection = zRangeIntersection  {
            return Cuboid(xRange: xRangeIntersection, yRange: yRangeIntersection, zRange: zRangeIntersection)
        }
        return nil
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let instructions = buildInstructions(from: input)

    var totalLitVolume = 0
    var onCuboids: [Cuboid] = []
    var offCuboids: [Cuboid] = []

    for i in instructions {
        let cuboid = Cuboid(xRange: i.xRange, yRange: i.yRange, zRange: i.zRange)
        let onLength = onCuboids.count
        let offLength = offCuboids.count

        if i.turnOn {
            totalLitVolume += cuboid.volume
            onCuboids.append(cuboid)
        }
        for onCuboidIndex in 0..<onLength {
            if let intersection = cuboid.getIntersectingCuboid(with: onCuboids[onCuboidIndex]) {
                offCuboids.append(intersection)
                totalLitVolume -= intersection.volume
            }
        }

        for offCuboidIndex in 0..<offLength {
            if let intersection = cuboid.getIntersectingCuboid(with: offCuboids[offCuboidIndex]) {
                onCuboids.append(intersection)
                totalLitVolume += intersection.volume
            }
        }

        print(totalLitVolume)
    }
}

private func buildInstructions(from input: [String]) -> [Instruction] {
    var instrs: [Instruction] = []
    let regex = Regex("^(\\w+) x=(-?\\d+..-?\\d+),y=(-?\\d+..-?\\d+),z=(-?\\d+..-?\\d+)")

    for i in input {
        let groups = regex.getMatches(in: i)
        let turnOn = groups[0] == "on"

        let xSplit = groups[1].components(separatedBy: "..")
        let xRange = Int(xSplit[0])!...Int(xSplit[1])!

        let ySplit = groups[2].components(separatedBy: "..")
        let yRange = Int(ySplit[0])!...Int(ySplit[1])!

        let zSplit = groups[3].components(separatedBy: "..")
        let zRange = Int(zSplit[0])!...Int(zSplit[1])!

        instrs.append(.init(turnOn: turnOn, xRange: xRange, yRange: yRange, zRange: zRange))
    }


    return instrs
}

struct Instruction {
    let turnOn: Bool
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let zRange: ClosedRange<Int>
}

try main()

