import Foundation

func main() throws {
    // REAL INPUT
    //    let grid: [[Character]] = [
    //        [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
    //        ["#", "#", "C", "#", "B", "#", "D", "#", "D", "#", "#"],
    //        ["#", "#", "D", "#", "B", "#", "B", "#", "A", "#", "#"],
    //        ["#", "#", "D", "#", "B", "#", "A", "#", "C", "#", "#"],
    //        ["#", "#", "B", "#", "C", "#", "A", "#", "A", "#", "#"]
    //    ]
    // TEST INPUT
    let grid: [[Character]] = [
        [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
        ["#", "#", "B", "#", "C", "#", "B", "#", "D", "#", "#"],
        //        ["#", "#", "D", "#", "C", "#", "B", "#", "A", "#", "#"],
        //        ["#", "#", "D", "#", "B", "#", "A", "#", "C", "#", "#"],
        ["#", "#", "A", "#", "D", "#", "C", "#", "A", "#", "#"]
    ]
    // COMPLETE GAME
    //    let grid: [[Character]] = [
    //        [".", "A", ".", ".", ".", ".", ".", ".", ".", ".", "."],
    //        ["#", "#", ".", "#", "B", "#", "C", "#", "D", "#", "#"],
    //        ["#", "#", "A", "#", "B", "#", "C", "#", "D", "#", "#"],
    //        ["#", "#", "A", "#", "B", "#", "C", "#", "D", "#", "#"],
    //        ["#", "#", "A", "#", "B", "#", "C", "#", "D", "#", "#"]
    //    ]

    let game = Game(grid: grid)

    typealias Memo = [Game: Int?]
    var memo: Memo = [:]

    /// Takes a game and returns the minimum energy needed to complete the game
    func playGame(game: Game, memo: inout Memo) -> Int? {
        if let memoResult = memo[game] { return memoResult }
        if game.finished { print("A game has finished"); return 0 }

        var energyNeededForMoves: [Int] = []

        // Get all possible moves
        let possibleMoves = game.possibleMoves
        if possibleMoves.count == 0 { memo[game] = nil; return nil }
        for m in possibleMoves {
            if let nextResult = playGame(game: game.executeMove(m), memo: &memo) {
                energyNeededForMoves.append(m.2 + nextResult)
            }
        }
        if energyNeededForMoves.count == 0 { memo[game] = nil; return nil }

        let minimum = energyNeededForMoves.min()!
        memo[game] = minimum
        return minimum
    }

    print(playGame(game: game, memo: &memo))
}

struct Game: Hashable {
    let roomColumns = [2, 4, 6, 8]
    let possibleCorridorStopColumns = [0, 1, 3, 5, 7, 9, 10]
    let SPACE: Character = "."
    let grid: [[Character]]
    var corridor: [Character] { grid[0] }
    let roomSize: Int

    init(grid: [[Character]]) {
        self.grid = grid
        self.roomSize = grid.count - 1
    }

    var finished: Bool { isRoomComplete(2) && isRoomComplete(4) && isRoomComplete(6) && isRoomComplete(8) }
    var populatedCorridorIndexes: [Int] { (0..<corridor.count).filter({ corridor[$0] != SPACE }) }

    func executeMove(_ move: Move) -> Game {
        var nextGrid = grid
        // swap round the origin and destination chars
        nextGrid[move.1.y][move.1.x] = grid[move.0.y][move.0.x]
        nextGrid[move.0.y][move.0.x] = grid[move.1.y][move.1.x]

        return Game(grid: nextGrid)
    }

    // MARK: - Possible move functions
    typealias Move = (Coordinate, Coordinate, Int)
    var possibleMoves: [Move] {
        var moves: [Move] = []
        // First, do the corridor, want to move an item in the corridor into a room
        moves.append(contentsOf: possibleMovesFromCorridor)
        // Next, move from rooms to corridor
        moves.append(contentsOf: possibleMovesFromRooms)

        return moves
    }

    private var possibleMovesFromCorridor: [Move] {
        var moves: [Move] = []
        let populatedCorridorIndexes = populatedCorridorIndexes
        for corridorIndex in populatedCorridorIndexes {
            // Get the room's index that the character in the corridor can move into
            let characterInCorridor = corridor[corridorIndex]
            let destinationRoomColumnIndex = getRoomColumnIndex(for: characterInCorridor)

            if !canMoveFrom(columnIndex: corridorIndex, to: destinationRoomColumnIndex) { continue }
            if let availableRow = getNextAvailableRow(for: destinationRoomColumnIndex) {
                moves.append(buildMove(origin: Coordinate(corridorIndex, 0), destination: Coordinate(destinationRoomColumnIndex, availableRow)))
            }
        }
        return moves
    }

    private var possibleMovesFromRooms: [Move] {
        let availableColumns = possibleCorridorStopColumns.filter({ corridor[$0] == SPACE })
        // Go through each room, if it isn't complete move the top most item into each corridor slot
        var moves: [Move] = []
        for roomColumnIndex in roomColumns {
            if isRoomComplete(roomColumnIndex) { continue }
            let roomContent = getRoom(roomColumnIndex)
            if doesRoomContainValidChars(roomContent, roomIndex: roomColumnIndex) { continue }
            if isRoomEmpty(roomContent) { continue }
            let indexToMove = (0..<roomSize).first(where: { roomContent[$0] != SPACE })! + 1
            let origin = Coordinate(roomColumnIndex, indexToMove)

            // Find which cols you can move to
            // first, left
            var availableCols: [Int] = []
            for col in possibleCorridorStopColumns {
                if canMoveFrom(columnIndex: roomColumnIndex, to: col) {
                    availableCols.append(col)
                }
            }
            //            print(availableColumns, availableCols)
            moves.append(contentsOf: availableCols.map({ buildMove(origin: origin, destination: Coordinate($0, 0)) }))
        }
        return moves
    }

    // MARK: - Room functions
    private func getNextAvailableRow(for roomIndex: Int) -> Int? {
        // Get the content of the room
        let roomContent = getRoom(roomIndex)

        // If room is full, no available row
        if isRoomFull(roomContent) { return nil }

        // The room isn't full, so check if the content is valid
        guard doesRoomContainValidChars(roomContent, roomIndex: roomIndex) else { return nil }

        // The room contains valid chars so get the bottom most empty space
        for i in stride(from: roomSize, to: 0, by: -1) {
            let roomChar = roomContent[i-1]
            if roomChar == SPACE {
                return i
            }
        }

        return nil
    }

    private func doesRoomContainValidChars(_ room: [Character], roomIndex: Int) -> Bool {
        let expectedChar = getExpectedChar(for: roomIndex)
        // An unexpected char is one where it's not expected and it's not a space
        if let unexpectedChar = room.first(where: { $0 != expectedChar && $0 != SPACE }) {
            return false
        }
        return true
    }

    private func canMoveFrom(columnIndex: Int, to destinationColumnIndex: Int) -> Bool {
        let direction = columnIndex < destinationColumnIndex ? 1 : -1
        let colsToMoveBetween = stride(from: columnIndex + direction, to: destinationColumnIndex + direction, by: direction)
        let populatedCols = populatedCorridorIndexes
//        print("can move from \(columnIndex) to \(destinationColumnIndex) pop \(populatedCols)")
        for c in colsToMoveBetween {
            if populatedCols.contains(c) {
//                print("Returning false")
                return false
            }
        }
//        print("Returning true")
        return true
    }

    private func isRoomFull(_ room: [Character]) -> Bool {
        let spaces = room.filter({ $0 == SPACE })
        return spaces.count == 0
    }

    private func isRoomEmpty(_ room: [Character]) -> Bool {
        let spaces = room.filter({ $0 == SPACE })
        return spaces.count == roomSize
    }

    private func isRoomComplete(_ roomColumnIndex: Int) -> Bool {
        let room = getRoom(roomColumnIndex)
        let expectedChar = getExpectedChar(for: roomColumnIndex)
        if room.first(where: { $0 != expectedChar }) != nil {
            return false
        }
        return true
    }

    private func getRoom(_ roomColumnIndex: Int) -> [Character] {
        (1..<grid.count).map({ grid[$0][roomColumnIndex] })
    }

    // MARK: - Mappings
    private func getRoomColumnIndex(for character: Character) -> Int {
        ["A": 2, "B": 4, "C": 6, "D": 8][character]!
    }

    private func getExpectedChar(for room: Int) -> Character {
        [2: "A", 4: "B", 6: "C", 8: "D"][room]!
    }

    // MARK: - Move creation
    private func buildMove(origin: Coordinate, destination: Coordinate) -> Move {
        let mhd = origin.getManhattanDistance(to: destination)
        let char = grid[origin.y][origin.x]
        let cost = getEnergyUsed(for: char, moves: mhd)
        return (origin, destination, cost)
    }

    private func getEnergyUsed(for character: Character, moves: Int) -> Int {
        ["A": 1, "B": 10, "C": 100, "D": 1000][character]! * moves
    }
}

try main()

