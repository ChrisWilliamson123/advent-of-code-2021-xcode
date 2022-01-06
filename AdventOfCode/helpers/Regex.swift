import Foundation

struct Regex {
    private let regex: NSRegularExpression

    init(_ regex: String) {
        self.regex = try! NSRegularExpression(pattern: regex)
    }

    func doesMatch(_ text: String) -> Bool {
        let textRange = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, options: [], range: textRange) != nil
    }

    func getMatches(in text: String, includeFullLengthMatch: Bool = false) -> [String] {
        let textRange = NSRange(text.startIndex..., in: text)

        let matches = regex.matches(in: text, range: textRange)
        guard let match = matches.first else { return [] }

        return (0..<match.numberOfRanges).compactMap({
            let matchRange = match.range(at: $0)

            if matchRange == textRange, !includeFullLengthMatch { return nil }

            guard let substringRange = Range(matchRange, in: text) else { return nil }
            return String(text[substringRange])
        })
    }

    func getGreedyMatches(in text: String) -> [String] {
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results.map { String(text[Range($0.range, in: text)!]) }
    }
}
