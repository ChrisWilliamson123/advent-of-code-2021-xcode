import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n\n")

    let rules = input[0].split(separator: "\n")
    let messages = input[1].split(separator: "\n").map({ String($0) })

    var ruleTree: [Int: String] = [:]

    for r in rules {
//        print(r)
        let split = r.components(separatedBy: ": ")
        let orSplit = split[1].components(separatedBy: " | ")
        if orSplit.count == 2 {
            let lhs = orSplit[0].split(separator: " ").map({ "(?:\($0))" }).joined()
            let rhs = orSplit[1].split(separator: " ").map({ "(?:\($0))" }).joined()
//            print(lhs, rhs)
            ruleTree[Int(split[0])!] = "(?:\(lhs)|\(rhs))"
        } else {
            let values = orSplit[0].split(separator: " ")
//            print(values)
            ruleTree[Int(split[0])!] = values.map({ "(?:\($0))" }).joined()
        }
    }

//    print(ruleTree)

    func expandRule(tree: [Int: String], rule: Int) -> String {
        let ruleValue = tree[rule]!
        let numberRegex = Regex("\\d+")
        let matches = numberRegex.getMatches(in: ruleValue)
        if matches.count == 0 { return ruleValue }

        var result = ""
        var index = 0

        while index < ruleValue.count {
            let nextChar: String = ruleValue[index]
            if Int(nextChar) != nil {
                var numberIndex = index + 1
                while let numberChar = Int(ruleValue[numberIndex]) {
                    numberIndex += 1
                }
                let number = Int(ruleValue[index..<numberIndex])!
                let numberRule = expandRule(tree: tree, rule: number)
                result += numberRule
                index += (numberIndex - index)
            } else {
                result += nextChar
                index += 1
            }
        }

        return result.replacingOccurrences(of: "\"", with: "")
    }

    let rule = expandRule(tree: ruleTree, rule: 0)
    let regex = Regex(rule)

    let fullMatches = messages.filter({
        let matches = regex.getMatches(in: $0, includeFullLengthMatch: true)
        return matches.count == 1 && matches[0].count == $0.count
    })

    let notFullMatches = messages.filter({
        let matches = regex.getMatches(in: $0, includeFullLengthMatch: true)
        return !(matches.count == 1 && matches[0].count == $0.count)
    })
    print(fullMatches)

    print("\n\n")

    print(notFullMatches)
}

try main()

