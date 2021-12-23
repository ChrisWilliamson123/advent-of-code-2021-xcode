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
    let grid: [[Character]] = [
        [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
        ["#", "#", "C", "#", "B", "#", "D", "#", "D", "#", "#"],
        ["#", "#", "B", "#", "C", "#", "A", "#", "A", "#", "#"]
    ]
    // TEST INPUT
//    let grid: [[Character]] = [
//        [".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "."],
//        ["#", "#", "B", "#", "C", "#", "B", "#", "D", "#", "#"],
//        ["#", "#", "A", "#", "D", "#", "C", "#", "A", "#", "#"]
//    ]
    // COMPLETE GAME
//    let grid: [[Character]] = [
//        [".", "A", ".", ".", ".", ".", ".", ".", ".", ".", "."],
//        ["#", "#", ".", "#", "B", "#", "C", "#", "D", "#", "#"],
//        ["#", "#", "A", "#", "B", "#", "C", "#", "D", "#", "#"]
//    ]

    let game = Game(grid: grid)

    typealias Memo = [Game: Int]
    var memo: Memo = [:]

    /// Takes a game and returns the minimum energy needed to complete the game
    func playGame(game: Game, memo: inout Memo) -> Int {
        if let memoResult = memo[game] { return memoResult }
        if game.hasGameFinished() {
            print("A game has finished")
            return 0
        }

        var energyNeededForMoves: [Int] = []

        // Get all possible moves
        let possibleMoves = game.getPossibleMoves()
        for m in possibleMoves {
            energyNeededForMoves.append(m.3 + playGame(game: game.executeMove(m), memo: &memo))
//            energyNeededForMoves.append
        }
        let minimum = energyNeededForMoves.min()!
        memo[game] = minimum
        return minimum
    }

    print(playGame(game: game, memo: &memo))


//    let moves = game.getPossibleMoves()
//    for m in moves {
//        print(m)
//    }
//
//    let nextGame = game.executeMove(moves[0])
//
//    for r in nextGame.grid {
//        print(r)
//    }

}

struct Game: Hashable {
    let roomColumns = [2, 4, 6, 8]
    let possibleCorridorStopColumns = [0, 1, 3, 5, 7, 9, 10]
    let SPACE: Character = "."
    let grid: [[Character]]
    var corridor: [Character] { grid[0] }

    func hasGameFinished() -> Bool {
        grid[1][roomColumns[0]] == "A" && grid[2][roomColumns[0]] == "A" &&
        grid[1][roomColumns[1]] == "B" && grid[2][roomColumns[1]] == "B" &&
        grid[1][roomColumns[2]] == "C" && grid[2][roomColumns[2]] == "C" &&
        grid[1][roomColumns[3]] == "D" && grid[2][roomColumns[3]] == "D"
    }

    func executeMove(_ move: Move) -> Game {
        var nextGrid = grid
        // swap round the origin and destination chars
        let originChar = move.1
        let destinationChar = grid[move.2.y][move.2.x]
        nextGrid[move.2.y][move.2.x] = originChar
        nextGrid[move.0.y][move.0.x] = destinationChar

        return Game(grid: nextGrid)
    }

    /// e.g. ((2,1), "C", (0,0), 300)
    typealias Move = (Coordinate, Character, Coordinate, Int)
    func getPossibleMoves() -> [Move] {
        var moves: [Move] = []
        /*
         First consider the corridor.
         An element already in the corridor can only move into it's slot if:
         1) The destination slot is empty OR only contains other valid chars
         2) There is a clear path from the elements start position to the room
         */
        let corridor = corridor
        for corridorSlotIndex in 0..<corridor.count {
            if corridor[corridorSlotIndex] == SPACE { continue }
            let characterAtSlot = corridor[corridorSlotIndex]
            let coordinate = Coordinate(corridorSlotIndex, 0)
            let roomIsAvailable = roomCanReceive(for: characterAtSlot)
            if roomIsAvailable.canReceive {
                let receivingCoordinate: Coordinate
                if roomIsAvailable.roomIsEmpty {
                    // Go to the bottom, y=2
                    receivingCoordinate = Coordinate(getDestinationColumn(for: characterAtSlot), 2)
                } else {
                    // Go to the top, y=1
                    receivingCoordinate = Coordinate(getDestinationColumn(for: characterAtSlot), 1)
                }
                moves.append(buildMove(origin: coordinate, destination: receivingCoordinate))
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
        if spaces.count == 2 { return nil }

        // Room is full so return top
        if roomIsFull(room) { return Coordinate(room, 1) }
        // Room isn't full so return bottom, only if bottom isn't in correct col
        let expCharForRoom = getExpectedChar(for: room)
        if r[1] != expCharForRoom {
            return Coordinate(room, 2)
        }
        return nil
    }

    private func roomIsCorrect(_ room: Int) -> Bool {
        let expectedChar = getExpectedChar(for: room)
        let slotsWithExpectedChar = getDestinationRoom(for: expectedChar).filter({ $0 == expectedChar })
        if slotsWithExpectedChar.count == 2 { return true }
        return false
    }

    private func roomIsFull(_ room: Int) -> Bool {
        let room = getRoom(room)
        let spaces = room.filter({ $0 == SPACE })
        return spaces.count == 0
    }


    // Will return true if the room for the character is available to take the character
    private func roomCanReceive(for character: Character) -> (canReceive: Bool, roomIsEmpty: Bool) {
        let room = getDestinationRoom(for: character)

        // Room is full
        if room[0] != "." && room[1] != "." { return (false, false) }

        // Room is empty
        if room[0] == "." && room[1] == "." { return (true, true) }

        // If the room contains a non-destination character, return false
        if room.contains(where: { $0 != character && $0 != "." }) { return (false, false) }

        // Room contains one empty slot and the other char is a matching one for that room
        return (true, false)
    }

    private func getRoom(_ room: Int) -> [Character] {
        [grid[1][room], grid[2][room]]
    }

    // 0 is top room and 1 is bottom room
    private func getDestinationRoom(for character: Character) -> [Character] {
        let column = getDestinationColumn(for: character)
        return [grid[1][column], grid[2][column]]
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

