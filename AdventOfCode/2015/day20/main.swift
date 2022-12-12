import Foundation

func main() throws {
    let factorsInput: [String] = try readInput(fileName: "factors.txt")
    var index = 1
    let factors: [Int: Set<Int>] = factorsInput.reduce(into: [:], { $0[index] = Set($1.split(separator: ",").map({Int($0)!})); index += 1 })
    print("Built factors dict")

    var house = 1
    while factors[house]!.reduce(0, +) * 10 < 34000000 {
        house += 1
    }
    print("Part one:", house)

    house = 1
    while factors[house]!.filter({ house / $0 <= 50 }).reduce(0, +) * 11 < 34000000 {
        house += 1
    }

    print("Part two:", house)
}

Timer.time(main)
