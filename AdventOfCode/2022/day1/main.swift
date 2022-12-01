import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let inventories = input.map { $0.split(separator: "\n").map { string in Int(string)! } }

    let sums = inventories.map { $0.reduce(0, +) }
    print(sums.max()!)
    let sorted = sums.sorted(by: { $1 < $0 })
    let topThreeSum = sorted[0..<3].reduce(0, +)
    print(topThreeSum)
}

try main()
