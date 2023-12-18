import Foundation

enum Tile: String, CustomStringConvertible {
    case open = "."
    case wall = "#"
    case closed = "*"

    var description: String { rawValue }
}

enum Direction: String {
    case right = "R"
    case left = "L"
    case up = "U"
    case down = "D"
}

enum Instruction {
    case move(Int)
    case rotate(Direction)
}

enum Face: Hashable {
    case top
    case bottom
    case front
    case back
    case left
    case right
}

struct FaceDirection: Hashable {
    let face: Face
    let direction: Coordinate
}

open class Cube {
    static let DIRECTIONS: [Coordinate] = [.init(1, 0), .init(0, 1), .init(-1, 0), .init(0, -1)]
    private let faces: [Face: [ClosedRange<Int>]]
    private let directionChanges: [FaceDirection: FaceDirection]
    private let grid: [[Tile]]
    private let movementInstructions: [Instruction]
    var currentPosition: Coordinate
    private var directionsIndex: Int = 0
    private var currentDirection: Coordinate { Self.DIRECTIONS[directionsIndex] }
    var score: Int {
        ((currentPosition.y+1) * 1000) + ((currentPosition.x+1) * 4) + directionsIndex
    }

    var currentFace: Face {
        for (face, ranges) in faces {
            if ranges[0].contains(currentPosition.y) && ranges[1].contains(currentPosition.x) {
                return face
            }
        }
        assert(false, "Could not find face for current position")
    }

    init(grid: [[Tile]], movementInstructions: [Instruction], directionChanges: [FaceDirection: FaceDirection], faces: [Face: [ClosedRange<Int>]]) {
        self.grid = grid
        self.currentPosition = Coordinate(grid[0].firstIndex(where: { $0 == .open })!, 0)
        self.movementInstructions = movementInstructions
        self.directionChanges = directionChanges
        self.faces = faces
        self.currentPosition = Coordinate(grid[0].firstIndex(where: { $0 == .open })!, 0)
    }

    func performMoves() {
        for i in movementInstructions {
            move(using: i)
        }
    }

    private func move(using instruction: Instruction) {
        /**
         In a move we need to:
         1. Try to move forward the correct number of places, wrapping round or stopping if needed
         */
        switch instruction {
        case .move(let movementAmount):
            for _ in 0..<movementAmount {
                let oldFace = currentFace
                let nextTileCoord = currentPosition + currentDirection
                if !tileIsInFace(tile: nextTileCoord, face: oldFace) {
                    let nextFace = getNextFace(currentFace: oldFace, direction: currentDirection)
                    let oldPos = currentPosition
                    translateFrom(currentFace: oldFace, destinationFace: nextFace, change: currentDirection)
                    if grid[currentPosition.y][currentPosition.x] == .wall {
                        currentPosition = oldPos
                    } else {
                        let newDirection = directionChanges[FaceDirection(face: oldFace, direction: currentDirection)]!.direction
                        directionsIndex = Self.DIRECTIONS.firstIndex(of: newDirection)!
                    }
                } else {
                    let oldPos = currentPosition
                    currentPosition = nextTileCoord
                    if grid[nextTileCoord.y][nextTileCoord.x] == .wall {
                        currentPosition = oldPos
                    }
                }
            }
        case .rotate(let direction):
            switch direction {
            case .right: directionsIndex = (directionsIndex + 1) % Self.DIRECTIONS.count
            case .left:
                directionsIndex = (directionsIndex - 1)
                if directionsIndex < 0 {
                    directionsIndex = Self.DIRECTIONS.count - 1
                } else {
                    directionsIndex = directionsIndex % Self.DIRECTIONS.count
                }
            default: assert(false, "Invalid turn direction")
            }
        }
    }

    private func tileIsInFace(tile: Coordinate, face: Face) -> Bool {
        faces[face]![0].contains(tile.y) && faces[face]![1].contains(tile.x)
    }

    private func getNextFace(currentFace: Face, direction: Coordinate) -> Face {
        directionChanges[FaceDirection(face: currentFace, direction: direction)]!.face
    }

    func getRangeForFaceAndAxis(face: Face, axis: Coordinate.Axis) -> ClosedRange<Int> {
        faces[face]![axis == .y ? 0 : 1]
    }

    func getOffsetForFaceAndAxis(face: Face, axis: Coordinate.Axis) -> Int {
        let pos = axis == .x ? currentPosition.x : currentPosition.y
        return pos - getRangeForFaceAndAxis(face: face, axis: axis).lowerBound
    }

    func translateFrom(currentFace: Face, destinationFace: Face, change: Coordinate) {
        assert(false, "A superclass must implement this function")
    }
}

final class RealCube: Cube {
    init(grid: [[Tile]], movementInstructions: [Instruction]) {
        super.init(grid: grid,
                   movementInstructions: movementInstructions,
                   directionChanges: [
                    .init(face: .bottom, direction: .init(1, 0)): .init(face: .right, direction: .init(0, -1)),
                    .init(face: .bottom, direction: .init(-1, 0)): .init(face: .left, direction: .init(0, 1)),
                    .init(face: .bottom, direction: .init(0, 1)): .init(face: .front, direction: .init(0, 1)),
                    .init(face: .bottom, direction: .init(0, -1)): .init(face: .back, direction: .init(0, -1)),

                    .init(face: .back, direction: .init(1, 0)): .init(face: .right, direction: .init(1, 0)),  // back going right
                    .init(face: .back, direction: .init(-1, 0)): .init(face: .left, direction: .init(1, 0)), // back going left
                    .init(face: .back, direction: .init(0, 1)): .init(face: .bottom, direction: .init(0, 1)),  // back going down
                    .init(face: .back, direction: .init(0, -1)): .init(face: .top, direction: .init(1, 0)), // back going up

                    .init(face: .left, direction: .init(1, 0)): .init(face: .front, direction: .init(1, 0)),  // left going right
                    .init(face: .left, direction: .init(-1, 0)): .init(face: .back, direction: .init(1, 0)), // left going left
                    .init(face: .left, direction: .init(0, 1)): .init(face: .top, direction: .init(0, 1)),  // left going down
                    .init(face: .left, direction: .init(0, -1)): .init(face: .bottom, direction: .init(1, 0)), // left going up

                    .init(face: .right, direction: .init(1, 0)): .init(face: .front, direction: .init(-1, 0)),  // right going right
                    .init(face: .right, direction: .init(-1, 0)): .init(face: .back, direction: .init(-1, 0)), // right going left
                    .init(face: .right, direction: .init(0, 1)): .init(face: .bottom, direction: .init(-1, 0)),  // right going down // NOT SURE
                    .init(face: .right, direction: .init(0, -1)): .init(face: .top, direction: .init(0, -1)), // right going up

                    .init(face: .front, direction: .init(1, 0)): .init(face: .right, direction: .init(-1, 0)),  // front going right
                    .init(face: .front, direction: .init(-1, 0)): .init(face: .left, direction: .init(-1, 0)), // front going left
                    .init(face: .front, direction: .init(0, 1)): .init(face: .top, direction: .init(-1, 0)),  // front going down
                    .init(face: .front, direction: .init(0, -1)): .init(face: .bottom, direction: .init(0, -1)), // front going up

                    .init(face: .top, direction: .init(1, 0)): .init(face: .front, direction: .init(0, -1)),  // top going right
                    .init(face: .top, direction: .init(-1, 0)): .init(face: .back, direction: .init(0, 1)), // top going left
                    .init(face: .top, direction: .init(0, 1)): .init(face: .right, direction: .init(0, 1)),  // top going down
                    .init(face: .top, direction: .init(0, -1)): .init(face: .left, direction: .init(0, -1)) // top going up
                ], faces: [
                    .top: [150...199, 0...49],
                    .left: [100...149, 0...49],
                    .back: [0...49, 50...99],
                    .bottom: [50...99, 50...99],
                    .front: [100...149, 50...99],
                    .right: [0...49, 100...149]
                ])
    }

    override func translateFrom(currentFace: Face, destinationFace: Face, change: Coordinate) {
        switch (currentFace, destinationFace) {
        case (.top, .back):
            let newY = getRangeForFaceAndAxis(face: .back, axis: .y).lowerBound
            let yOffset = getOffsetForFaceAndAxis(face: .top, axis: .y)
            let newX = getRangeForFaceAndAxis(face: .back, axis: .x).lowerBound + yOffset
            currentPosition = .init(newX, newY)
        case (.top, .front):
            let newY = getRangeForFaceAndAxis(face: .front, axis: .y).upperBound
            let yOffset = getOffsetForFaceAndAxis(face: .top, axis: .y)
            let newX = getRangeForFaceAndAxis(face: .front, axis: .x).lowerBound + yOffset
            currentPosition = .init(newX, newY)
        case (.top, .right):
            let newY = getRangeForFaceAndAxis(face: .right, axis: .y).lowerBound
            let xOffset = getOffsetForFaceAndAxis(face: .top, axis: .x)
            let newX = getRangeForFaceAndAxis(face: .right, axis: .x).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.left, .back):
            let newX = getRangeForFaceAndAxis(face: .back, axis: .x).lowerBound
            let yOffset = getOffsetForFaceAndAxis(face: .left, axis: .y)
            let newY = getRangeForFaceAndAxis(face: .back, axis: .y).upperBound - yOffset
            currentPosition = .init(newX, newY)
        case (.left, .bottom):
            let newX = getRangeForFaceAndAxis(face: .bottom, axis: .x).lowerBound
            let xOffset = getOffsetForFaceAndAxis(face: .left, axis: .x)
            let newY = getRangeForFaceAndAxis(face: .bottom, axis: .y).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.front, .right):
            let newX = getRangeForFaceAndAxis(face: .right, axis: .x).upperBound
            let yOffset = getOffsetForFaceAndAxis(face: .front, axis: .y)
            let newY = getRangeForFaceAndAxis(face: .right, axis: .y).upperBound - yOffset
            currentPosition = .init(newX, newY)
        case (.front, .top):
            let newX = getRangeForFaceAndAxis(face: .top, axis: .x).upperBound
            let xOffset = getOffsetForFaceAndAxis(face: .front, axis: .x)
            let newY = getRangeForFaceAndAxis(face: .top, axis: .y).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.bottom, .left):
            let newY = getRangeForFaceAndAxis(face: .left, axis: .y).lowerBound
            let yOffset = getOffsetForFaceAndAxis(face: .bottom, axis: .y)
            let newX = getRangeForFaceAndAxis(face: .left, axis: .x).lowerBound + yOffset
            currentPosition = .init(newX, newY)
        case (.bottom, .right):
            let newY = getRangeForFaceAndAxis(face: .right, axis: .y).upperBound
            let yOffset = getOffsetForFaceAndAxis(face: .bottom, axis: .y)
            let newX = getRangeForFaceAndAxis(face: .right, axis: .x).lowerBound + yOffset
            currentPosition = .init(newX, newY)
        case (.back, .left):
            let newX = getRangeForFaceAndAxis(face: .left, axis: .x).lowerBound
            let yOffset = getOffsetForFaceAndAxis(face: .back, axis: .y)
            let newY = getRangeForFaceAndAxis(face: .left, axis: .y).upperBound - yOffset
            currentPosition = .init(newX, newY)
        case (.back, .top):
            let newX = getRangeForFaceAndAxis(face: .top, axis: .x).lowerBound
            let xOffset = getOffsetForFaceAndAxis(face: .back, axis: .x)
            let newY = getRangeForFaceAndAxis(face: .top, axis: .y).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.right, .bottom):
            let newX = getRangeForFaceAndAxis(face: .bottom, axis: .x).upperBound
            let xOffset = getOffsetForFaceAndAxis(face: .right, axis: .x)
            let newY = getRangeForFaceAndAxis(face: .bottom, axis: .y).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.right, .top):
            let newY = getRangeForFaceAndAxis(face: .top, axis: .y).upperBound
            let xOffset = getOffsetForFaceAndAxis(face: .right, axis: .x)
            let newX = getRangeForFaceAndAxis(face: .top, axis: .x).lowerBound + xOffset
            currentPosition = .init(newX, newY)
        case (.right, .front):
            let newX = getRangeForFaceAndAxis(face: .front, axis: .x).upperBound
            let yOffset = getOffsetForFaceAndAxis(face: .right, axis: .y)
            let newY = getRangeForFaceAndAxis(face: .front, axis: .y).upperBound - yOffset
            currentPosition = .init(newX, newY)
        default:
            currentPosition += change
        }

    }
}

class Board {
    static let DIRECTIONS: [Coordinate] = [.init(1, 0), .init(0, 1), .init(-1, 0), .init(0, -1)]
    let grid: [[Tile]]
    let movementInstructions: [Instruction]
    var directionsIndex = 0
    var currentPosition: Coordinate
    var currentDirection: Coordinate { Self.DIRECTIONS[directionsIndex] }
    var visited: Set<Coordinate> = []

    var score: Int {
        ((currentPosition.y+1) * 1000) + ((currentPosition.x+1) * 4) + directionsIndex
    }

    init(grid: [[Tile]], movementInstructions: [Instruction]) {
        self.grid = grid
        self.currentPosition = Coordinate(grid[0].firstIndex(where: { $0 == .open })!, 0)
        self.movementInstructions = movementInstructions
        visited.insert(currentPosition)
    }

    func performMoves() {
        for i in movementInstructions {
            move(using: i)
        }
    }

    func move(using instruction: Instruction) {
        /**
         In a move we need to:
         1. Try to move forward the correct number of places, wrapping round or stopping if needed
         */
        switch instruction {
        case .move(let movementAmount):
            for _ in 0..<movementAmount {
                var nextTileCoord = currentPosition + currentDirection
                if currentDirection.y == 0 {
                    if !isValidXPosition(for: nextTileCoord.y, xPos: nextTileCoord.x) {
                        if currentDirection.x == 1 {
                            nextTileCoord = Coordinate(getFirstNonClosedColumnIndex(for: currentPosition.y)!, currentPosition.y)
                        } else {
                            nextTileCoord = Coordinate(getLastNonClosedColumnIndex(for: currentPosition.y)!, currentPosition.y)
                        }
                    }
                } else {
                    if !isValidYPosition(for: nextTileCoord.x, yPos: nextTileCoord.y) {
                        if currentDirection.y == 1 {
                            nextTileCoord = Coordinate(currentPosition.x, getFirstNonClosedRowIndex(for: currentPosition.x)!)
                        } else {
                            nextTileCoord = Coordinate(currentPosition.x, getLastNonClosedRowIndex(for: currentPosition.x)!)
                        }
                    }
                }
                let nextTile = grid[nextTileCoord.y][nextTileCoord.x]
                switch nextTile {
                case .open: currentPosition = nextTileCoord
                case .wall: break
                case .closed:
                    // If we're moving on x axis
                    if currentDirection.y == 0 {
                        // If we're moving right
                        if currentDirection.x == 1 {
                            // Get the first x index on this row
                            if let firstXIndex = grid[currentPosition.y].firstIndex(where: { $0 == .open }) {
                                currentPosition = Coordinate(firstXIndex, currentPosition.y)
                            } else {
                                // There is no other free coord on this row, so stick where we are
                                break
                            }
                        }
                        // We're moving left
                        else {
                            // Get the last x index on this row
                            if let lastXIndex = grid[currentPosition.y].lastIndex(where: { $0 == .open }) {
                                currentPosition = Coordinate(lastXIndex, currentPosition.y)
                            } else {
                                // There is no other free coord on this row, so stick where we are
                                break
                            }
                        }
                    }
                    // We're moving on x axis
                    else {
                        // If we're moving down
                        if currentDirection.y == 1 {
                            // Get the first y index on this row
                            if let firstYIndex = grid.firstIndex(where: { $0[currentDirection.x] == .open }) {
                                currentPosition = Coordinate(currentPosition.x, firstYIndex)
                            } else {
                                // There is no other free coord on this col, so stick where we are
                                break
                            }
                        }
                        // We're moving up
                        else {
                            // Get the last x index on this row
                            if let lastYIndex = grid.lastIndex(where: { $0[currentPosition.x] == .open }) {
                                currentPosition = Coordinate(currentPosition.x, lastYIndex)
                            } else {
                                // There is no other free coord on this row, so stick where we are
                                break
                            }
                        }
                    }
                }
                visited.insert(currentPosition)
            }
        case .rotate(let direction):
            switch direction {
            case .right: directionsIndex = (directionsIndex + 1) % Self.DIRECTIONS.count
            case .left:
                directionsIndex = (directionsIndex - 1)
                if directionsIndex < 0 {
                    directionsIndex = Self.DIRECTIONS.count - 1
                } else {
                    directionsIndex = directionsIndex % Self.DIRECTIONS.count
                }
            default: assert(false, "Invalid turn direction")
            }
        }
    }

    private func isValidYPosition(for column: Int, yPos: Int) -> Bool {
        let validYPositionRange = getFirstNonClosedRowIndex(for: column)!...getLastNonClosedRowIndex(for: column)!
        return validYPositionRange.contains(yPos)
    }

    private func isValidXPosition(for row: Int, xPos: Int) -> Bool {
        let validXPositionRange = getFirstNonClosedColumnIndex(for: row)!...getLastNonClosedColumnIndex(for: row)!
        return validXPositionRange.contains(xPos)
    }

    private func getFirstNonClosedColumnIndex(for row: Int) -> Int? {
        grid[row].firstIndex(where: { $0 != .closed })!
    }

    private func getLastNonClosedColumnIndex(for row: Int) -> Int? {
        grid[row].lastIndex(where: { $0 != .closed })!
    }

    private func getFirstNonClosedRowIndex(for column: Int) -> Int? {
        grid.firstIndex(where: { $0[column] != .closed })!
    }

    private func getLastNonClosedRowIndex(for column: Int) -> Int? {
        grid.lastIndex(where: { $0[column] != .closed })!
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")

    let tiles = input[0].components(separatedBy: "\n").map { line in line.compactMap { Tile.init(rawValue: String($0)) } }
    let instructionLines = input[1].components(separatedBy: "\n")
    let instructions = instructionLines[0..<instructionLines.count-1].map {
        if let asInt = Int($0) {
            return Instruction.move(asInt)
        } else {
            return Instruction.rotate(Direction.init(rawValue: $0)!)
        }
    }
    let board = Board(grid: tiles, movementInstructions: instructions)
    board.performMoves()
    print(board.score)

    let cube = RealCube(grid: tiles, movementInstructions: instructions)
    cube.performMoves()
    print(cube.score)
}

Timer.time(main)
