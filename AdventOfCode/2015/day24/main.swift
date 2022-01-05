import Foundation

func main() throws {
    let packageWeights: [Int] = try readInput(fromTestFile: false)
    let packageCount = packageWeights.count

    let groupWeight: Int = packageWeights.sum() / 4

    print(groupWeight, packageCount)

//    let smallest = [113, 109, 107, 101, 89, 1]
    let smallest = [113, 109, 107, 61]
    let partOne = smallest.multiply()
    print(partOne)


}

try main()
