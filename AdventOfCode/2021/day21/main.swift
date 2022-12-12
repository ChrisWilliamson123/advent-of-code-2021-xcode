import Foundation

func main() throws {
    /*
     On each turn player rolls die three times and adds up results
     Moves forwards that many times around the track e.g.
     On 7, roll 2, 2, 1. Move 5 times to 8, 9, 10, 1, 2

     Increase score by value of space stopped on

     Game ends when a player reaches >= 1000

     Part, 1 use dice where it first rolls 1, then 2 up to 100 then back to 1 (modulo?)
     */

    var playerPositions = [7, 10]
    var playerScores = [0, 0]
    var turn = 0

    while playerScores.max()! < 1000 {
        // Whose turn is it?
        let playerInTurn = turn % 2

        // Perform the rolls
        let rolls = [((turn * 3) % 100) + 1, (((turn * 3) + 1) % 100) + 1, (((turn * 3) + 2) % 100) + 1]
        let rollsSum = rolls.sum()

        // Get the final position
        var finalPosition = (playerPositions[playerInTurn] + rollsSum) % 10
        if finalPosition == 0 { finalPosition = 10 }
        playerPositions[playerInTurn] = finalPosition

        // Increase the players score
        playerScores[playerInTurn] += finalPosition

        turn += 1
    }

    print("Part 1:", playerScores.min()! * (turn * 3))

    typealias Memo = [[Int]: [Int]]
    var memo: Memo = [:]
    // Returns an array where the first element is 1 if player 1 wins and vice versa
    func play(pos1: Int, score1: Int, pos2: Int, score2: Int, memo: inout Memo) -> [Int] {
        if let memoResult = memo[[pos1, score1, pos2, score2]] { return memoResult }
        if score1 >= 21 || score2 >= 21 {
            if score1 > score2 {
                memo[[pos1, score1, pos2, score2]] = [1, 0]
                return [1, 0]
            }
            else {
                memo[[pos1, score1, pos2, score2]] = [0, 1]
                return [0, 1]

            }
        }
        var result = [0, 0]

        /*
         Go through each combination of rolls (27) and get the new position and score for the player passed as player one.
         Then play the turn for the next player by switching round who player 1 is
         */
        for firstRoll in 1...3 {
            for secondRoll in 1...3 {
                for thirdRoll in 1...3 {
                    let newPosition = (pos1 + firstRoll + secondRoll + thirdRoll) % 10
                    let newScore = score1 + newPosition + 1

                    let other = play(pos1: pos2, score1: score2, pos2: newPosition, score2: newScore, memo: &memo)
                    result[0] += other[1]
                    result[1] += other[0]
                }
            }
        }
        memo[[pos1, score1, pos2, score2]] = result
        return result
    }

    let result = play(pos1: 6, score1: 0, pos2: 9, score2: 0, memo: &memo)

    print("Part 2:", result.max()!)
}

Timer.time(main)

