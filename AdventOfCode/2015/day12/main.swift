import Foundation

func main() throws {
    let inputJSON: String = try readInput(fromTestFile: false)[0]

    let numbersSum = matches(for: "(-?\\d+)", in: inputJSON).map({ Int($0)! }).sum()
    print(numbersSum)
}

private func matches(for regex: String, in text: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

try main()
