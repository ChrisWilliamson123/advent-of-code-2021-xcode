import Foundation

func main() throws {
//    var stacks: [[String]] = [
//        ["Z", "N"],
//        ["M", "C", "D"],
//        ["P"]
//    ]
    var stacks = [
        ["B","Q","C",],
        ["R","Q","W","Z",],
        ["B","M","R","L","V",],
        ["C","Z","H","V","T","W",],
        ["D","Z","H","B","N","V","G",],
        ["H","N","P","C","J","F","V","Q",],
        ["D","G","T","R","W","Z","S"],
        ["C","G","M","N","B","W","Z","P",],
        ["N","J","B","M","W","Q","F","P",]
    ]
    let input: [String] = try readInput(fromTestFile: false)
    let moves = input.filter({ $0.starts(with: "move") }).map({
        let regex = Regex("move (\\d+) from (\\d+) to (\\d+)")
        let matches = regex.getMatches(in: $0).map { Int($0)! }
        return matches
    })

    for m in moves {
        let moveFrom = m[1]-1
        let moveTo = m[2]-1
        let moveAmount = m[0]

        var toAppend: [String] = []
        for _ in 0..<moveAmount {
            let current = stacks[moveFrom].popLast()!
            toAppend.insert(current, at: 0)
        }
        stacks[moveTo].append(contentsOf: toAppend)
    }

    print(stacks.map({ $0[$0.count-1] }).joined())
}

Timer.time(main)
