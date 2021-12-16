import Foundation

func main() throws {
    let input: [Int] = try readInput(fromTestFile: false)

    let increasesP1 = (1..<input.count).reduce(0, { (currentIncreases, index) in
        input[index] > input[index-1] ? currentIncreases + 1 : currentIncreases
    })

    print("Part 1: \(increasesP1)")

    let increasesP2 = (1..<(input.count - 2)).reduce(0, { (currentIncreases, index) in
        let previousWindowSum = input[index-1...index+1].sum()
        let windowSum = input[index...index+2].sum()
        return windowSum > previousWindowSum ? currentIncreases + 1 : currentIncreases
    })

    print("Part 2: \(increasesP2)")
}

try main()
