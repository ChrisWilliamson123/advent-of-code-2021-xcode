import Foundation

func main() throws {
    let expressions: [String] = try readInput(fromTestFile: false)

    func getSignedMatches(from input: String, sign: Character) -> [String] {
        let regexString = "(\\d+(?: \\\(sign) \\d+)+)"

        let string = input
        let re = try! NSRegularExpression(pattern: regexString, options: [])
        let regexMatches = re.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        var matches: [String] = []
        for match in regexMatches as [NSTextCheckingResult] {
            let substring = (string as NSString).substring(with: match.range(at: 1))
            matches.append(substring)
        }

        return matches
    }

    func getExpressionResults(from expressions: [String], char: Character) -> [String: Int] {
        return expressions.reduce(into: [:], {
            let split = $1.components(separatedBy: " \(char) ").map({Int($0)!})
            let result = char == "*" ? split.multiply() : split.sum()
            $0[$1] = result
        })
    }

    func calculateFlatExpression(_ expression: String) -> Int {
        var mutable = expression
        // Do plusses first
        let plusExpressions = getSignedMatches(from: mutable, sign: "+")
        let plusResults = getExpressionResults(from: plusExpressions, char: "+")
        for (k, v) in plusResults.sorted(by: { $0.key.count > $1.key.count }) { mutable = mutable.replacingOccurrences(of: k, with: "\(v)") }

        let timesExpressions = getSignedMatches(from: mutable, sign: "*")
        if timesExpressions.isEmpty {
            return Int(mutable)!
        }
        let timesResults = getExpressionResults(from: timesExpressions, char: "*")
        return timesResults.values.first!
    }

    func calculate(_ expression: String) -> (Int, Int) {
        var index = 0
        var toCalculate = ""

        while index < expression.count {
            let nextChar: String = expression[index]
            switch nextChar {
            case "(":
                let subTotal = calculate(expression[index+1..<expression.count])
                toCalculate += "\(subTotal.0)"
                index += (subTotal.1+1)
            case ")":
                return (calculateFlatExpression(toCalculate), index)
            default:
                toCalculate += nextChar
            }
            index += 1
        }
        let toReturn = calculateFlatExpression(toCalculate)
        return (toReturn, index)
    }

    print("Part 2:", expressions.map({ calculate($0).0 }).sum())

}

Timer.time(main)
