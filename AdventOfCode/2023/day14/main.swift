import Foundation

private func canMoveUp(rockIndex: Int, column: [Character]) -> Bool {
    if rockIndex == 0 { return false }
    if column[rockIndex-1] == "." { return true }
    return false
}

private func canMoveLeft(rockIndex: Int, row: [Character]) -> Bool {
    if rockIndex == 0 { return false }
    if row[rockIndex-1] == "." { return true }
    return false
}

private func canMoveDown(rockIndex: Int, column: [Character]) -> Bool {
    if rockIndex == column.count - 1 { return false }
    if column[rockIndex+1] == "." { return true }
    return false
}

private func canMoveRight(rockIndex: Int, row: [Character]) -> Bool {
    if rockIndex == row.count - 1 { return false }
    if row[rockIndex+1] == "." { return true }
    return false
}

// swiftlint:disable:next cyclomatic_complexity function_body_length
func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let grid: [[Character]] = input.map { [Character]($0) }
    let columns = (0..<grid[0].count).map({ colIndex in grid.map({ row in row[colIndex] }) })

    var total = 0

    for col in columns {
        var newColumn: [Character] = col
        let rockIndexes = newColumn.indices.filter({ newColumn[$0] == "O" })
        for rockIndex in rockIndexes {
            var currentIndex = rockIndex
            var moveUp = canMoveUp(rockIndex: currentIndex, column: newColumn)
            while moveUp {
                let newIndex = currentIndex - 1
                newColumn[newIndex] = "O"
                newColumn[currentIndex] = "."
                currentIndex = newIndex
                moveUp = canMoveUp(rockIndex: currentIndex, column: newColumn)
            }
        }

        let load = newColumn.indices.filter({ newColumn[$0] == "O" }).map({ newColumn.count - $0 }).sum()
        total += load
    }
    print(total)

    var newGrid = grid
    let cycles = 1000000000
    var seen: [[[Character]]: (Int, Int)] = [:]
    for cycle in 0..<cycles {
        // Move north
        var columns = (0..<newGrid[0].count).map({ colIndex in newGrid.map({ row in row[colIndex] }) })
        var newCols: [[Character]] = []
        for col in columns {
            var newColumn: [Character] = col
            let rockIndexes = newColumn.indices.filter({ newColumn[$0] == "O" })
            for rockIndex in rockIndexes {
                var currentIndex = rockIndex
                var moveUp = canMoveUp(rockIndex: currentIndex, column: newColumn)
                while moveUp {
                    let newIndex = currentIndex - 1
                    newColumn[newIndex] = "O"
                    newColumn[currentIndex] = "."
                    currentIndex = newIndex
                    moveUp = canMoveUp(rockIndex: currentIndex, column: newColumn)
                }
            }

            newCols.append(newColumn)
        }
        newGrid = newCols.reversed().rotatedRight()

        // Move west
        var newRows: [[Character]] = []
        for row in newGrid {
            var newRow: [Character] = row
            let rockIndexes = newRow.indices.filter({ newRow[$0] == "O" })
            for rockIndex in rockIndexes {
                var currentIndex = rockIndex
                var moveLeft = canMoveLeft(rockIndex: currentIndex, row: newRow)
                while moveLeft {
                    let newIndex = currentIndex - 1
                    newRow[newIndex] = "O"
                    newRow[currentIndex] = "."
                    currentIndex = newIndex
                    moveLeft = canMoveLeft(rockIndex: currentIndex, row: newRow)
                }
            }

            newRows.append(newRow)
        }

        newGrid = newRows

        // Move south
        columns = (0..<newGrid[0].count).map({ colIndex in newGrid.map({ row in row[colIndex] }) })
        newCols = []
        for col in columns {
            var newColumn: [Character] = col
            let rockIndexes = newColumn.indices.filter({ newColumn[$0] == "O" })
            for rockIndex in rockIndexes.reversed() {
                var currentIndex = rockIndex
                var moveDown = canMoveDown(rockIndex: currentIndex, column: newColumn)
                while moveDown {
                    let newIndex = currentIndex + 1
                    newColumn[newIndex] = "O"
                    newColumn[currentIndex] = "."
                    currentIndex = newIndex
                    moveDown = canMoveDown(rockIndex: currentIndex, column: newColumn)
                }
            }

            newCols.append(newColumn)
        }
        newGrid = Array(newCols.reversed()).rotatedRight()

        // Move east
        newRows = []
        for row in newGrid {
            var newRow: [Character] = row
            let rockIndexes = newRow.indices.filter({ newRow[$0] == "O" })
            for rockIndex in rockIndexes.reversed() {
                var currentIndex = rockIndex
                var moveLeft = canMoveRight(rockIndex: currentIndex, row: newRow)
                while moveLeft {
                    let newIndex = currentIndex + 1
                    newRow[newIndex] = "O"
                    newRow[currentIndex] = "."
                    currentIndex = newIndex
                    moveLeft = canMoveRight(rockIndex: currentIndex, row: newRow)
                }
            }

            newRows.append(newRow)
        }

        newGrid = newRows

        if let seenCycle = seen[newGrid] {
            print("Seen this state at cycle \(seenCycle.0). CC = \(cycle). L = \(seenCycle.1)")
        } else {
            let cols = (0..<newGrid[0].count).map({ colIndex in newGrid.map({ row in row[colIndex] }) })
            var totalLoad = 0
            for col in cols {
                let load = col.indices.filter({ col[$0] == "O" }).map({ col.count - $0 }).sum()
                totalLoad += load
            }
            seen[newGrid] = (cycle, totalLoad)
        }
    }
}

Timer.time(main)
