import Foundation

enum PipePiece: Character, Hashable {
    case horiz = "-"
    case vert = "|"
    case ne = "L"
    case nw = "J"
    case sw = "7"
    case se = "F"
    case start = "S"
    
    var validConnections: [[PipePiece]?] {
        let westFacing: [PipePiece] = [.horiz, .nw, .sw, .start]
        let northFacing: [PipePiece] = [.vert, .nw, .ne, .start]
        let southFacing: [PipePiece] = [.vert, .se, .sw, .start]
        let eastFacing: [PipePiece] = [.horiz, .ne, .se, .start]
        // piece: [N, E, S, W]
        let mapping: [PipePiece: [[PipePiece]?]] = [
            .horiz: [nil, westFacing, nil, eastFacing],
            .vert:  [southFacing, nil, northFacing, nil],
            .ne:    [southFacing, westFacing, nil, nil],
            .nw:    [southFacing, nil, nil, eastFacing],
            .sw:    [nil, nil, northFacing, eastFacing],
            .se:    [nil, westFacing, northFacing, nil],
            .start: [southFacing, westFacing, northFacing, eastFacing]
        ]
        return mapping[self]!
    }
}

struct PipeMaze {
    let grid: [[Character]]
    let startPosition: Coordinate
    let coordsToPipes: [Coordinate: PipePiece]
    let coordsToChars: [Coordinate: Character]
    
    init(grid: [[Character]], startPosition: Coordinate) {
        self.grid = grid
        self.startPosition = startPosition
        
        var coordsToPipes: [Coordinate: PipePiece] = [:]
        var coordsToChars: [Coordinate: Character] = [:]
        for (yIndex, row) in grid.enumerated() {
            for (xIndex, character) in row.enumerated() {
                let coord = Coordinate(xIndex, yIndex)
                if let pipePiece = PipePiece(rawValue: character) {
                    coordsToPipes[coord] = pipePiece
                }
                coordsToChars[coord] = character
            }
        }
        self.coordsToPipes = coordsToPipes
        self.coordsToChars = coordsToChars
    }
    
    func getPipeConnections(at coordinate: Coordinate) -> Set<Coordinate> {
        guard let sourcePipePiece = coordsToPipes[coordinate] else { assert(false, "Could not get pipe at coord \(coordinate)") }

        let inRangeNeighbourCoords = coordinate.getAxialAdjacents(in: grid)
        return inRangeNeighbourCoords.reduce(into: Set<Coordinate>(), { currentSet, potentialNeighbour in
            let diff = potentialNeighbour - coordinate
            let connectionsIndexes = [
                Coordinate(0, -1): 0,
                Coordinate(-1, 0): 3,
                Coordinate(0, 1): 2,
                Coordinate(1, 0): 1,
            ]
            let validConnections = sourcePipePiece.validConnections
            if let neighbourPipePiece = coordsToPipes[potentialNeighbour] {
                let validConnectionsForSourceToAttachTo = validConnections[connectionsIndexes[diff]!] ?? []
                if validConnectionsForSourceToAttachTo.contains(neighbourPipePiece) {
                    currentSet.insert(potentialNeighbour)
                }
            }
        })
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    
    var start: Coordinate!
    let grid = input.enumerated().map({ (yIndex, line) in
        if let xIndex = line.firstIndex(of: "S") {
            start = Coordinate(line.distance(from: line.startIndex, to: xIndex), yIndex)
        }
        return [Character](line)
    })
    
    let pipeMaze = PipeMaze(grid: grid, startPosition: start)
    
    // Follow pipes until back at source
    var current = pipeMaze.getPipeConnections(at: pipeMaze.startPosition).first!
    var path = [pipeMaze.startPosition, current]
    while current != pipeMaze.startPosition {
        let next = pipeMaze.getPipeConnections(at: current).filter({ $0 != path[path.count - 2] })
        current = next.first!
        path.append(current)
    }
    print((path.count - 1) / 2)
    
    // PART 2
    let loopCoords = Set(path)
    var inLoop = 0
    for (yIndex, row) in pipeMaze.grid.enumerated() {
        if yIndex == 0 || yIndex == grid.count - 1 {
            continue
        }
        var count = 0
        var inGrid = false
        for (xIndex, _) in row.enumerated() {
            let coord = Coordinate(xIndex, yIndex)
            if loopCoords.contains(coord) && [PipePiece.vert, PipePiece.nw, PipePiece.ne, PipePiece.start].contains(pipeMaze.coordsToPipes[coord]) {
                inGrid.toggle()
            }
            if !loopCoords.contains(coord) {
                if inGrid {
                    count += 1
                }
            }
        }
        inLoop += count
    }
    print(inLoop)
}

// 615 too high
Timer.time(main)
