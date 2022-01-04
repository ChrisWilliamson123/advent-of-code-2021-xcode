import Foundation

func main() throws {
    let factorsInput: [String] = try readInput(fileName: "factors.txt")
    var index = 1
    let factors: [Int: Set<Int>] = factorsInput.reduce(into: [:], { $0[index] = Set($1.split(separator: ",").map({Int($0)!})); index += 1 })
    var house = 1
    while factors[house]!.filter({ house / $0 <= 50 }).reduce(0, +) * 11 < 34000000 {
        if house % 10000 == 0 { print(house) }
        house += 1
    }

    print(house)
}

try main()
