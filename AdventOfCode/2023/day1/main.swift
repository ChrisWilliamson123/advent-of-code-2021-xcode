import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    var total = 0
    for line in input {
        var l = line
        let mapping = [
            ("oneight", "18"),
            ("threeight", "38"),
            ("fiveight", "58"),
            ("nineight", "98"),
            ("eightwo", "82"),
            ("sevenine", "79"),
            ("twone", "21"),
            ("one", "1"),
            ("two", "2"),
            ("three", "3"),
            ("four", "4"),
            ("five", "5"),
            ("six", "6"),
            ("seven", "7"),
            ("eight", "8"),
            ("nine", "9")
        ]
        for (key, value) in mapping {
            l = l.replacingOccurrences(of: key, with: value)
        }
        var numbers = Regex("\\d").getGreedyMatches(in: l)
        let numberString = "\(numbers[0])\(numbers.last!)"
        total += Int(numberString)!
        print(line, total)
    }
    print(total)
}

Timer.time(main)
