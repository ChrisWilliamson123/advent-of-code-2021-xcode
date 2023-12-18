import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let numbersToDraw: [Int] = input[0].split(separator: ",").compactMap({ Int($0) })

    let partOneBingoGame = BingoGame(numbersToDraw: numbersToDraw.reversed(), boards: buildBingoBoards(from: Array(input.suffix(from: 1))))
    partOneBingoGame.play()
    print("Part 1: \(partOneBingoGame.finalWinningScore)")

    let partTwoBingoGame = BingoGame(numbersToDraw: numbersToDraw.reversed(), boards: buildBingoBoards(from: Array(input.suffix(from: 1))))
    partTwoBingoGame.playUntilEveryoneWins()
    print("Part 2: \(partTwoBingoGame.finalWinningScore)")
}

class BingoGame {
    private var numbersToDraw: [Int]
    private let boards: [BingoBoard]
    private var winners: [BingoBoard] = []
    private var previouslyPlayedNumber = 0

    var finalWinningScore: Int { winners[winners.count - 1].calculateWinningScore(using: previouslyPlayedNumber) }

    init(numbersToDraw: [Int], boards: [BingoBoard]) {
        self.numbersToDraw = numbersToDraw
        self.boards = boards
    }

    func play() {
        while let numberToPlay = numbersToDraw.popLast(), winners.isEmpty {
            playNumber(numberToPlay)
        }
    }

    func playUntilEveryoneWins() {
        while let numberToPlay = numbersToDraw.popLast(), winners.count < boards.count {
            playNumber(numberToPlay)
        }
    }

    private func playNumber(_ numberToPlay: Int) {
        boards.forEach({ board in
            board.checkNumber(numberToPlay)
            if board.hasWon && !boardHasFinished(board) {
                winners.append(board)
            }
        })
        previouslyPlayedNumber = numberToPlay
    }

    private func boardHasFinished(_ board: BingoBoard) -> Bool {
        winners.contains(where: { $0 === board })
    }
}

class BingoBoard {
    private typealias Row = [BoardPosition]
    private typealias Column = [BoardPosition]

    private var board: [Row]

    private var unmarkedSum: Int { board.flatMap({ $0 }).filter({ !$0.marked }).map({ $0.value }).sum() }
    private var allRows: [Row] { (0..<board.count).map(getRow) }
    private var allColumns: [Row] { (0..<board[0].count).map(getColumn) }
    private var allRowsAndAllColumns: [[BoardPosition]] { allRows + allColumns }

    var hasWon: Bool { allRowsAndAllColumns.contains(where: isWinningCollection) }

    init(board: [[Int]]) {
        self.board = board.map({ boardRow in
            boardRow.map({ BoardPosition(value: $0) })
        })
    }

    func checkNumber(_ number: Int) {
        for i in (0..<board.count) {
            for j in (0..<board[i].count) {
                if board[i][j].value == number {
                    board[i][j].marked = true
                }
            }
        }
    }

    func calculateWinningScore(using winningNumber: Int) -> Int {
        winningNumber * unmarkedSum
    }

    private func getRow(_ rowIndex: Int) -> [BoardPosition] {
        board[rowIndex]
    }

    private func isWinningCollection(_ boardPositions: [BoardPosition]) -> Bool {
        boardPositions.first(where: { !$0.marked }) == nil
    }

    private func getColumn(_ columnIndex: Int) -> [BoardPosition] {
        board.map({ $0[columnIndex] })
    }

    private struct BoardPosition {
        let value: Int
        var marked: Bool

        init(value: Int) {
            self.value = value
            self.marked = false
        }
    }
}

private func buildBingoBoards(from input: [String]) -> [BingoBoard] {
    stride(from: 0, through: input.count - 5, by: 5).map({ bingoBoardStartIndex in
        let boardNumbers = input[bingoBoardStartIndex..<bingoBoardStartIndex+5]
            .flatMap({ $0.split(separator: " ").compactMap({Int($0)}) })

        let stride = stride(from: 0, through: boardNumbers.count - 5, by: 5)
        return BingoBoard(board: stride.map({ startIndex in
            Array(boardNumbers[startIndex..<startIndex+5])
        }))
    })
}

Timer.time(main)
