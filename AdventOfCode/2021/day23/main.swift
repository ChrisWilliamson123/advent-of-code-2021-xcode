import Foundation

func main() throws {
    /*
     #############
     #...........#
     ###C#B#D#D###
       #B#C#A#A#
       #########
     */
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
        ["#", "#", "D", "#", "C", "#", "B", "#", "A", "#", "#"],
        ["#", "#", "D", "#", "B", "#", "A", "#", "C", "#", "#"],
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
            if game.finished {
                print("A game has finished")
                return 0
            }

            var energyNeededForMoves: [Int] = []

            // Get all possible moves
            let possibleMoves = game.possibleMoves
            if possibleMoves.count == 0 {
                memo[game] = nil
                return nil
            }
            for m in possibleMoves {
                let nextResult = playGame(game: game.executeMove(m), memo: &memo)
                if let nextResult = nextResult {
                    energyNeededForMoves.append(m.3 + nextResult)
                }
    //            energyNeededForMoves.append
            }
            if energyNeededForMoves.count == 0 {
                memo[game] = nil
                return nil
            }
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
        let originChar = move.1
        let destinationChar = grid[move.2.y][move.2.x]
        nextGrid[move.2.y][move.2.x] = originChar
        nextGrid[move.0.y][move.0.x] = destinationChar

        return Game(grid: nextGrid)
    }

    // MARK: - Possible move functions
    typealias Move = (Coordinate, Character, Coordinate, Int)
    var possibleMoves: [Move] {
        var moves: [Move] = []
        // First, do the corridor, want to move an item in the corridor into a room
        moves.append(contentsOf: possibleMovesFromCorridor)
        // Next, move from rooms to corridor
        moves.append(contentsOf: possibleMovesFromRooms)

        return moves
    }

    var possibleMovesFromCorridor: [Move] {
        var moves: [Move] = []
        let populatedCorridorIndexes = populatedCorridorIndexes
        for corridorIndex in populatedCorridorIndexes {
            // Get the room's index that the character in the corridor can move into
            let characterInCorridor = corridor[corridorIndex]
            let destinationRoomIndex = getRoomColumnIndex(for: characterInCorridor)

            if let availableRow = getNextAvailableRow(for: destinationRoomIndex) {
                moves.append(buildMove(origin: Coordinate(corridorIndex, 0), destination: Coordinate(destinationRoomIndex, availableRow)))
            }
        }
        return moves
    }

    var possibleMovesFromRooms: [Move] {
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
            for i in stride(from: roomColumnIndex-1, to: -1, by: -1) {
                if availableColumns.contains(i) {
                    availableCols.append(i)
                } else {
                    break
                }
            }
            for i in stride(from: roomColumnIndex+1, to: grid[0].count, by: 1) {
                if availableColumns.contains(i) {
                    availableCols.append(i)
                } else {
                    break
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
        [
            "A": 2,
            "B": 4,
            "C": 6,
            "D": 8
        ][character]!
    }

    private func getExpectedChar(for room: Int) -> Character {
        [
            2: "A",
            4: "B",
            6: "C",
            8: "D"
        ][room]!
    }

    // MARK: - Move creation
    private func buildMove(origin: Coordinate, destination: Coordinate) -> Move {
        let mhd = origin.getManhattanDistance(to: destination)
        let char = grid[origin.y][origin.x]
        let cost = getEnergyUsed(for: char, moves: mhd)
        return (origin, char, destination, cost)
    }

    private func getEnergyUsed(for character: Character, moves: Int) -> Int {
        [
            "A": 1,
            "B": 10,
            "C": 100,
            "D": 1000
        ][character]! * moves
    }
}

struct DeepGame: Hashable {
    let roomColumns = [2, 4, 6, 8]
    let possibleCorridorStopColumns = [0, 1, 3, 5, 7, 9, 10]
    let SPACE: Character = "."
    let grid: [[Character]]
    var corridor: [Character] { grid[0] }

    func hasGameFinished() -> Bool {
        grid[1][roomColumns[0]] == "A" && grid[2][roomColumns[0]] == "A" && grid[3][roomColumns[0]] == "A" && grid[4][roomColumns[0]] == "A" &&
        grid[1][roomColumns[1]] == "B" && grid[2][roomColumns[1]] == "B" && grid[3][roomColumns[1]] == "B" && grid[4][roomColumns[1]] == "B" &&
        grid[1][roomColumns[2]] == "C" && grid[2][roomColumns[2]] == "C" && grid[3][roomColumns[2]] == "C" && grid[4][roomColumns[2]] == "C" &&
        grid[1][roomColumns[3]] == "D" && grid[2][roomColumns[3]] == "D" && grid[3][roomColumns[3]] == "D" && grid[4][roomColumns[3]] == "D"
    }

    func executeMove(_ move: Move) -> DeepGame {
        var nextGrid = grid
        // swap round the origin and destination chars
        let originChar = move.1
        let destinationChar = grid[move.2.y][move.2.x]
        nextGrid[move.2.y][move.2.x] = originChar
        nextGrid[move.0.y][move.0.x] = destinationChar

        return DeepGame(grid: nextGrid)
    }

    /// e.g. ((2,1), "C", (0,0), 300)
    typealias Move = (Coordinate, Character, Coordinate, Int)
    func getPossibleMoves() -> [Move] {
        var moves: [Move] = []
        /*
         First consider the corridor.
         An element already in the corridor can only move into it's slot if:
         1) The destination slot is empty OR only contains other valid chars
         */
        let corridor = corridor
        for corridorSlotIndex in 0..<corridor.count {
//            if corridor[corridorSlotIndex] == SPACE { continue }
//            let characterAtSlot = corridor[corridorSlotIndex]
//            let coordinate = Coordinate(corridorSlotIndex, 0)
//            if let receivalRow = getRoomReceivalRow(for: characterAtSlot) {
//                moves.append(buildMove(origin: coordinate, destination: Coordinate(getDestinationColumn(for: characterAtSlot), receivalRow)))
//            }
            if corridor[corridorSlotIndex] == SPACE { continue }
            let characterInSlot = corridor[corridorSlotIndex]
            let coordinate = Coordinate(corridorSlotIndex, 0)

            let destinationColumn = getDestinationColumn(for: characterInSlot)
            let room = getRoom(destinationColumn)
            print(room)
            if roomIsFull(destinationColumn) { continue }
            if roomIsEmpty(destinationColumn) { moves.append(buildMove(origin: coordinate, destination: Coordinate(destinationColumn, 4))) }
            // Room isn't full or empty
            // Check of room only contains correct char
            if !roomOnlyContainsCorrectChars(destinationColumn) { continue }
            // Need to get the bottom most empty slot, can start at 3 because we know the col isn't empty
            for i in [3, 2, 1] {
                if room[i-1] == SPACE {
                    moves.append(buildMove(origin: coordinate, destination: Coordinate(destinationColumn, i)))
                    break
                }
            }
        }

        /*
         Next consider each room.
         Only move from this room if either char is not matching the room's expected chars
         The top char in each room can move to any empty corridor space that isn't a room column and isn't occupied by another char
         */
        for room in roomColumns {
            guard let nextMoverCoord = getNextMoverCoordinateInRoom(room) else { continue }
            // Got the coord to move, can move to any open corridor col
            for colIndex in possibleCorridorStopColumns {
                let charInSlot = grid[0][colIndex]
                if charInSlot == SPACE {
                    moves.append(buildMove(origin: nextMoverCoord, destination: Coordinate(colIndex, 0)))
                }
            }
        }
        return moves
    }

    private func roomOnlyContainsCorrectChars(_ room: Int) -> Bool {
        let roomC = getRoom(room)
        let nonSpaceChars = Set(roomC.filter({ $0 != SPACE }))
        if nonSpaceChars.count == 1 && nonSpaceChars.first! == getExpectedChar(for: room) {
            return true
        }
        return false
    }

    private func buildMove(origin: Coordinate, destination: Coordinate) -> Move {
        let mhd = origin.getManhattanDistance(to: destination)
        let char = grid[origin.y][origin.x]
        let cost = getEnergyUsed(for: char, moves: mhd)
        return (origin, char, destination, cost)
    }

    // Will return the top char if the room is full, else return the bottom char
    private func getNextMoverCoordinateInRoom(_ room: Int) -> Coordinate? {
        // Room is correctly populated so don't move from it
        if roomIsCorrect(room) { return nil }

        // Room is empty space so return nil
        let r = getRoom(room)
        let spaces = r.filter({ $0 == SPACE })
        if spaces.count == 4 { return nil }

        // Room is full so return top
        if roomIsFull(room) {
            return Coordinate(room, 1)
        }


        // Room isn't correctly populated. Room isn't empty. Room isn't full
        // Therefore return the top most populated item
        for roomIndex in 1...4 {
            if r[roomIndex-1] != SPACE {
                return Coordinate(room, roomIndex)
            }
        }
        return nil
    }

    private func roomIsCorrect(_ room: Int) -> Bool {
        let expectedChar = getExpectedChar(for: room)
        let slotsWithExpectedChar = getDestinationRoom(for: expectedChar).filter({ $0 == expectedChar })
        if slotsWithExpectedChar.count == 4 { return true }
        return false
    }

    private func roomIsFull(_ room: Int) -> Bool {
        let room = getRoom(room)
        let spaces = room.filter({ $0 == SPACE })
        return spaces.count == 0
    }


    // Returns the next available row that the character can move to
    private func getRoomReceivalRow(for character: Character) -> Int? {
        let room = getDestinationRoom(for: character)

        for i in [4, 3, 2, 1] {
            if room[i-1] == SPACE { return i }
        }
        return nil

//        // If the room is full, the room can't receive
//        if room[0] != "." && room[1] != "." && room[2] != "." && room[3] != "." { return (false, false) }}
//
//        // Room is empty
//        if room[0] == "." && room[1] == "." && room[2] == "." && room[3] == "." { return (true, true) }
////
////        // If the room contains a non-destination character, return false
////        if room.contains(where: { $0 != character && $0 != "." }) { return (false, false) }
////
////        // Room contains at least one empty slot and the other chars are matching ones for that room
////        return (true, false)
    }

    private func roomIsEmpty(_ room: Int) -> Bool {
        let room = getRoom(room)
        let spaces = room.filter({ $0 == SPACE })
        return spaces.count == 4
    }

    private func getRoom(_ room: Int) -> [Character] {
        [grid[1][room], grid[2][room], grid[3][room], grid[4][room]]
    }

    // 0 is top room and 1 is bottom room
    private func getDestinationRoom(for character: Character) -> [Character] {
        let column = getDestinationColumn(for: character)
        return [grid[1][column], grid[2][column], grid[3][column], grid[4][column]]
    }

    private func getDestinationColumn(for character: Character) -> Int {
        [
            "A": 2,
            "B": 4,
            "C": 6,
            "D": 8
        ][character]!
    }

    private func getExpectedChar(for room: Int) -> Character {
        [
            2: "A",
            4: "B",
            6: "C",
            8: "D"
        ][room]!
    }

    private func getEnergyUsed(for character: Character, moves: Int) -> Int {
        [
            "A": 1,
            "B": 10,
            "C": 100,
            "D": 1000
        ][character]! * moves
    }
}


try main()

