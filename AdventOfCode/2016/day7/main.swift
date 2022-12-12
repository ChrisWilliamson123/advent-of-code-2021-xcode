import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let ips = input.map({ IPAddress(address: $0) })
    print("Part one:", ips.reduce(0, { $1.supportsTLS ? $0 + 1 : $0 }))
    print("Part two:", ips.reduce(0, { $1.supportsSSL ? $0 + 1 : $0 }))
}

struct IPAddress {
    let address: String

    var supportsTLS: Bool {
        let squareBracketsRegex = Regex("\\[\\w+\\]")
        let squareBracketsContents = squareBracketsRegex.getGreedyMatches(in: address).map({ $0[1..<$0.count-1] })

        let nonSquareRegex = Regex("(?<!\\[)\\b\\w+\\b(?![\\w\\s]*[\\]])")
        let nonSquareContents = nonSquareRegex.getGreedyMatches(in: address)

        let squaredContainsABBA = squareBracketsContents.first(where: { hasABBA($0) }) != nil
        let nonSquaredContainsABBA = nonSquareContents.first(where: { hasABBA($0) }) != nil

        if !squaredContainsABBA && nonSquaredContainsABBA { return true }

        return false
    }

    var supportsSSL: Bool {
        let squareBracketsRegex = Regex("\\[\\w+\\]")
        let squareBracketsContents = squareBracketsRegex.getGreedyMatches(in: address).map({ $0[1..<$0.count-1] })

        let nonSquareRegex = Regex("(?<!\\[)\\b\\w+\\b(?![\\w\\s]*[\\]])")
        let nonSquareContents = nonSquareRegex.getGreedyMatches(in: address)

        let ABAList = nonSquareContents.map({ getABAList($0) }).flatMap({ $0 })
        for sbc in squareBracketsContents {
            for aba in ABAList {
                if sbc.contains(aba[1] + aba[0] + aba[1]) {
                    return true
                }
            }
        }

        return false
    }

    private func hasABBA(_ input: String) -> Bool {
        for i in 3..<input.count {
            if input[i] == input[i-2] { continue }
            if [input[i-3], input[i-2]] == [input[i], input[i-1]] {
                return true
            }
        }

        return false
    }

    private func getABAList(_ input: String) -> [String] {
        var abaList = [String]()
        for i in 2..<input.count {
            if input[i] == input[i-2] && input[i] != input[i-1] {
                abaList.append(input[i-2...i])
            }
        }
        return abaList
    }
}

extension String {
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return }
    }
}

Timer.time(main)
