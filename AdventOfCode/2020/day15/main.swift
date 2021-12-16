import Foundation

func main(turns: Int, part: Int) throws {
    let input: [String] = try readInput(fromTestFile: false)

    let numbers: [Int] = input[0].split(separator: ",").map({Int($0)!})

    var numbersSpoken: [Int: (prevPrev: Int?, prev: Int)] = [:]
    var lastNumberSpoken: Int = 0

    for i in 0..<numbers.count {
        numbersSpoken[numbers[i]] = (nil, i)
        lastNumberSpoken = numbers[i]
    }

    for i in numbers.count..<turns {
        let lastSpokenNumber = lastNumberSpoken
        let numberInformation = numbersSpoken[lastSpokenNumber]!

        if numberInformation.prevPrev == nil {
            if let zeroInfo = numbersSpoken[0] {
                numbersSpoken[0] = (zeroInfo.prev, i)
            } else {
                numbersSpoken[0] = (nil, i)
            }
            lastNumberSpoken = 0
        } else {
            let turnsApart = numberInformation.prev - numberInformation.prevPrev!
            if let turnsApartInfo = numbersSpoken[turnsApart] {
                numbersSpoken[turnsApart] = (turnsApartInfo.prev, i)
            } else {
                numbersSpoken[turnsApart] = (nil, i)
            }
            lastNumberSpoken = turnsApart
        }

    }

    print("Part \(part):", lastNumberSpoken)
}

try main(turns: 2020, part: 1)
try main(turns: 30000000, part: 1)

