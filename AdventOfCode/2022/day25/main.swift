import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    print(input)
    let snafuNumbers = input.map { Array($0.reversed()) }
    print(snafuNumbers)

    var decimals = [Int]()
    for n in snafuNumbers {
        var total = 0
        for i in 0..<n.count {
            var multiplier = Int(pow(5, Double(i)))
            let number = try? Int(n[i]) ?? ["=": -2, "-": -1][n[i]]!
            total += number! * multiplier
        }
        decimals.append(total)
    }
    print(decimals.sum())

    let numbers = (0..<21).map { Int(pow(5, Double($0))) }
//    print(Array(numbers.reversed()))

    print(convertToDecimal("2=1-=02-21===-21=200"))
//    print(convertToDecimal("2=-1=0"))
}

private func convertToDecimal(_ snafu: String) -> Int {
    var reversed = Array(snafu.reversed())
    var total = 0
    for i in 0..<snafu.count {
        var multiplier = Int(pow(5, Double(i)))
        let number = try? Int(reversed[i]) ?? ["=": -2, "-": -1][reversed[i]]!
        total += number! * multiplier
    }
    return total
}

// 3125 625 125 25 5 1
(2*3125)-(625*2)-125+25-10+0

Timer.time(main)
