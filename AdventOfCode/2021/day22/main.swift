import Foundation
import simd

//public extension ClosedRange where Element : Comparable {
//
//    @warn_unused_result
//    public func intersect(other: ClosedRange<Element>) -> ClosedRange<Element> {
//        guard endIndex > other.startIndex else {
//            return endIndex...endIndex
//        }
//        guard other.endIndex > startIndex else {
//            return startIndex...startIndex
//        }
//        let s = other.startIndex > startIndex ? other.startIndex : startIndex
//        let e = other.endIndex < endIndex ? other.endIndex : endIndex
//        return s...e
//    }
//}

extension ClosedRange {
    public func intersect(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let lowerBoundMax = max(self.lowerBound, other.lowerBound)
        let upperBoundMin = min(self.upperBound, other.upperBound)

        let lowerBeforeUpper = lowerBoundMax <= self.upperBound && lowerBoundMax <= other.upperBound
        let upperBeforeLower = upperBoundMin >= self.lowerBound && upperBoundMin >= other.lowerBound

        if lowerBeforeUpper && upperBeforeLower {
            return lowerBoundMax...upperBoundMin
        }

        return nil
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true)
    let instructions = buildInstructions(from: input)

    var numberOfLitCubes = 27
    var xRanges: [ClosedRange<Int>] = [10...12]
    var yRanges: [ClosedRange<Int>] = [10...12]
    var zRanges: [ClosedRange<Int>] = [10...12]

    for i in instructions[0..<4] {
        if i.turnOn {
            let fullOnVolume = i.xRange.count * i.yRange.count * i.zRange.count

            var xIntersects = 0
            var yIntersects = 0
            var zIntersects = 0

            for index in 0..<xRanges.count {
                let r = xRanges[index]
                if let intersect = r.intersect(i.xRange) {
                    xIntersects += intersect.count
                    xRanges[index] = i.xRange
                }
            }
            for index in 0..<yRanges.count {
                let r = yRanges[index]
                if let intersect = r.intersect(i.yRange) {
                    yIntersects += intersect.count
                    yRanges[index] = i.yRange
                }
            }
            for index in 0..<zRanges.count {
                let r = zRanges[index]
                if let intersect = r.intersect(i.zRange) {
                    zIntersects += intersect.count
                    zRanges[index] = i.zRange
                }
            }
            numberOfLitCubes += fullOnVolume - (xIntersects * yIntersects * zIntersects)
        } else {
            var startXRangeSize = i.xRange.count
            var startYRangeSize = i.yRange.count
            var startZRangeSize = i.zRange.count

            for index in 0..<xRanges.count {
                let r = xRanges[index]
                if let intersect = r.intersect(i.xRange) {
                    print("Off x intersect", intersect)
                    startXRangeSize -= intersect.count
                }
            }
            for index in 0..<yRanges.count {
                let r = yRanges[index]
                if let intersect = r.intersect(i.yRange) {
//                    print("Off y intersect", intersect.count)
                    startYRangeSize -= intersect.count
                }
            }
            for index in 0..<zRanges.count {
                let r = zRanges[index]
                if let intersect = r.intersect(i.zRange) {
//                    print("Off z intersect", intersect.count)
                    startZRangeSize -= intersect.count
                }
            }
            print(startXRangeSize, startYRangeSize, startZRangeSize)
            numberOfLitCubes -= startXRangeSize * startYRangeSize * startZRangeSize
        }
        print(numberOfLitCubes)
        print("x ranges: ", xRanges)
        print("y ranges: ", yRanges)
        print("z ranges: ", zRanges)
    }



//
//    let partOneInstructions = instructions.filter({
//        ($0.xRange.lowerBound >= -50 && $0.yRange.lowerBound >= -50 && $0.zRange.lowerBound >= -50) &&
//        ($0.xRange.upperBound <= 50 && $0.yRange.upperBound <= 50 && $0.zRange.upperBound <= 50)
//    })
//    var onCubes: Set<simd_float3> = []
//    for i in instructions {
//        print("Executing instruction \(i)")
//        for x in i.xRange {
//            print(x)
//            for y in i.yRange {
//                for z in i.zRange {
//                    let coord = simd_float3(x: Float(x), y: Float(y), z: Float(z))
//                    if i.turnOn {
////                        print("\tInserting \(coord)")
//                        onCubes.insert(coord)
//                    }
//                    else {
////                        print("\tRemoving \(coord)")
//                        onCubes.remove(coord)
//                    }
//                }
//            }
//        }
//
////        print("\t\(onCubes.count)")
//    }
//    var onCubes: Set<simd_float3> = []
//    for x in [10, 12, 13] {
//        for y in [10, 12, 13] {
//            for z in [10, 12, 13] {
//                let coord = simd_float3(x: Float(x), y: Float(y), z: Float(z))
//                onCubes.insert(coord)
//            }
//        }
//    }
//
//    print(onCubes.count)
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

