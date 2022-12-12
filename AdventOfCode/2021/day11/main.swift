import Foundation

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)
    
    var game = Game(input)
    for _ in 0..<100 { game.tick() }
    print("Part 1:", game.flashesPerformed)

    game = Game(input)
    var counter = 0
    while !game.allPositionFlashedOnPreviousTick {
        game.tick()
        counter += 1
    }

    print("Part 2:", counter)
}

class Game {
    private var board: [[Int]]
    private var prevFlashed: Set<Coordinate> = []

    var flashesPerformed = 0    

    var allPositionFlashedOnPreviousTick: Bool {
        prevFlashed.count == (board.count * board[0].count)
    }


    init(_ startingBoard: [String]) {
        board = startingBoard.map({ [Character]($0).map({ Int($0)! }) })
    }

    func tick() {

        // Increase each by one
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                board[y][x] += 1
            }
        }

        // Perform the flashing
        var flashedCoords = Set<Coordinate>()
        var flashableCoords = getFlashableCoords(flashed: flashedCoords)
        while flashableCoords.count > 0 {
            for f in flashableCoords {
                flashedCoords.insert(f)
                flashesPerformed += 1
                let adjacents = f.getAdjacents(in: board)
                for a in adjacents {
                    board[a.y][a.x] += 1
                }
            }
            flashableCoords = getFlashableCoords(flashed: flashedCoords)
        }

        // If coords have flashed, set them back to 0
        for f in flashedCoords {
            board[f.y][f.x] = 0
        }

        prevFlashed = flashedCoords
    }

    private func getFlashableCoords(flashed: Set<Coordinate>) -> Set<Coordinate> {
        var flashableCoords: Set<Coordinate> = []
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                let coordinate = Coordinate(x, y)
                if board[y][x] > 9 && !flashed.contains(coordinate) {
                    flashableCoords.insert(coordinate)
                }
            }
        }

        return flashableCoords
    }
}

Timer.time(main)
