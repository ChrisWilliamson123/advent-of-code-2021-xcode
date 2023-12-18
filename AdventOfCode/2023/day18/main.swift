import Foundation

struct DigInstruction {
    let direction: String
    let distance: Int
    let edgeColor: String
    
    var directionCoordinate: Coordinate {
        switch direction {
        case "R": return Coordinate(1, 0)
        case "L": return Coordinate(-1, 0)
        case "U": return Coordinate(0, -1)
        case "D": return Coordinate(0, 1)
        default: assert(false, "Invalid direction found")
        }
    }
}

final class Lagoon {
    var diggerPosition: Coordinate = Coordinate(0, 0)
    let instructions: [DigInstruction]
    var dugCoordinates: Set<Coordinate> = [Coordinate(0, 0)]
    
    var bounds: (x: Range<Int>, y: Range<Int>) {
        (
            dugCoordinates.min(by: { $0.x < $1.x })!.x..<dugCoordinates.max(by: { $0.x < $1.x })!.x + 1,
            dugCoordinates.min(by: { $0.y < $1.y })!.y..<dugCoordinates.max(by: { $0.y < $1.y })!.y + 1
        )
    }
    
    init(instructions: [DigInstruction]) {
        self.instructions = instructions
    }
    
    func followInstructions() {
        var i = 0
        var limit = instructions.count
        instructions.forEach({ instruction in
            print("\(i)/\(limit)")
            let directionCoordinate = instruction.directionCoordinate
            for _ in 0..<instruction.distance {
                diggerPosition += directionCoordinate
                dugCoordinates.insert(diggerPosition)
            }
            i += 1
        })
    }
    
    func getInternalCoords() -> Set<Coordinate> {
        let bounds = self.bounds
        let topRow = (bounds.x.lowerBound - 1..<bounds.x.upperBound + 1).map({ Coordinate($0, bounds.y.lowerBound - 1) })
        let bottomRow = (bounds.x.lowerBound - 1..<bounds.x.upperBound + 1).map({ Coordinate($0, bounds.y.upperBound + 1) })
        let leftRow = (bounds.y.lowerBound - 1..<bounds.y.upperBound + 1).map({ Coordinate(bounds.x.lowerBound - 1, $0) })
        let rightRow = (bounds.y.lowerBound - 1..<bounds.y.upperBound + 1).map({ Coordinate(bounds.x.upperBound + 1, $0) })
        let target = Set(topRow + bottomRow + leftRow + rightRow)
        var internalCoords = Set<Coordinate>()
        
        for yIndex in stride(from: bounds.y.lowerBound, to: bounds.y.upperBound, by: 1000) {
//        for yIndex in bounds.y.lowerBound..<bounds.y.upperBound {
            for xIndex in stride(from: bounds.x.lowerBound, to: bounds.x.upperBound, by: 1000) {
//            for xIndex in bounds.x.lowerBound..<bounds.x.upperBound {
                print(xIndex, yIndex)
                let coord = Coordinate(xIndex, yIndex)
                guard !dugCoordinates.contains(coord) else { continue }
                
                // Try to reach one of the coords on the outside of the lagoon
                let result = bfs(graph: [] as Set<Coordinate>,
                                 source: coord,
                                 target: target) { coordinate in
                    Set(coordinate.adjacents.filter({ !dugCoordinates.contains($0) }))
                } getDistanceBetween: { _, _ in
                    1
                }
                // We could not reach top left if we do not have a distance to it, therefore this coordinate must be inside grid.
                // Therefore, return number of other coordinates we visited + 1 (+ 1 is for coord we start on)
                if !result.distances.contains(where: { target.contains($0.key) }) {
                    let dug = Set(Array(result.prev.keys) + [coord])
                    self.dugCoordinates = self.dugCoordinates.union(dug)
                    return dug
                }
            }
        }
        
        assert(false, "Could not get internal coord count")
    }
    
    func printLagoon() {
        let bounds = self.bounds
        for yIndex in bounds.y {
            var row = ""
            for xIndex in bounds.x {
                let coord = Coordinate(xIndex, yIndex)
                if dugCoordinates.contains(coord) {
                    row += "#"
                } else {
                    row += "."
                }
            }
            print(row)
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
//    let instructions: [DigInstruction] = input.map({
//        let split = $0.split(separator: " ")
//        return DigInstruction(direction: String(split[0]), distance: Int(String(split[1]))!, edgeColor: String(split[2])[1..<split[2].count])
//    })
//    
//    let lagoon = Lagoon(instructions: instructions)
//    lagoon.followInstructions()
//    _ = lagoon.getInternalCoords()
//    print(lagoon.dugCoordinates.count)
    
    let swappedInstructions = input.map({
        let split = $0.split(separator: " ")
        let hexCode = String(split[2])[2..<split[2].count-1]
        let distance = Int(hexCode[0..<hexCode.count-1], radix: 16)!
        switch hexCode[hexCode.length - 1] as Character {
        case "0": return DigInstruction(direction: "R", distance: distance, edgeColor: "a")
        case "1": return DigInstruction(direction: "D", distance: distance, edgeColor: "a")
        case "2": return DigInstruction(direction: "L", distance: distance, edgeColor: "a")
        case "3": return DigInstruction(direction: "U", distance: distance, edgeColor: "a")
        default: assert(false, "Invalid direction string")
        }
//        print(hexCode, distance)
//        return 1
    })
    print(swappedInstructions)
    
    let lagoon2 = Lagoon(instructions: swappedInstructions)
    lagoon2.followInstructions()
//    lagoon2.printLagoon()
    _ = lagoon2.getInternalCoords()
    print(lagoon2.dugCoordinates.count)
}

Timer.time(main)
