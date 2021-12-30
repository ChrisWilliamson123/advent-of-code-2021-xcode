import Foundation

func main() throws {
    var currentSequence: [Int] = [1,3,2,1,1,3,1,1,1,2]

    for i in 0..<50 {
        currentSequence = tick(seq: currentSequence)
        if i == 39 {
            print("Part one:", currentSequence.count)
        }
    }

    print("Part two:", currentSequence.count)
}

private func tick(seq: [Int]) -> [Int] {
    var currentNumber = seq[0]
    var currentCount = 1
    var index = 1

    var newSequence: [Int] = []
    while index < seq.count {
        let value = seq[index]
        if value != currentNumber {
            newSequence.append(contentsOf: [currentCount, currentNumber])
            currentCount = 1
            currentNumber = value
        } else {
            currentCount += 1
        }
        index += 1
    }
    newSequence.append(contentsOf: [currentCount, currentNumber])

    return newSequence
}

try main()
