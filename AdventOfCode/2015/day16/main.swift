import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let sues: [Sue] = input.map({
        let matches = matches(for: "(\\w+: \\d+)", in: $0)
        let compounds: [Compound: Int] = matches.reduce(into: [:], {
            let split = $1.components(separatedBy: ": ")
            $0[Compound.init(rawValue: split[0])!] = Int(split[1])!
        })
        return Sue(compounds: compounds)
    })

    let giftCompounds: [Compound: Int] = [
        .children: 3,
        .cats: 7,
        .samoyeds: 2,
        .pomeranians: 3,
        .akitas: 0,
        .vizslas: 0,
        .goldfish: 5,
        .trees: 3,
        .cars: 2,
        .perfumes: 1
    ]

    let validSues = sues.filter({ sue in
        for (key, value) in sue.compounds {
            switch key {
            case .trees, .cats: if value <= giftCompounds[key]! { return false }
            case .pomeranians, .goldfish: if value >= giftCompounds[key]! { return false }
            default: if giftCompounds[key]! != value { return false }
            }
        }
        return true
    })

    print(sues.firstIndex(of: validSues[0])! + 1)
}

struct Sue: Equatable {
    let compounds: [Compound: Int]
}

enum Compound: String, Hashable {
    case cars
    case akitas
    case goldfish
    case children
    case samoyeds
    case perfumes
    case pomeranians
    case trees
    case vizslas
    case cats
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

Timer.time(main)
