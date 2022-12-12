import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let ingredients: [Ingredient] = input.map({
        let regex = Regex("(\\w+): capacity (-?\\d+), durability (-?\\d+), flavor (-?\\d+), texture (-?\\d+), calories (-?\\d+)")
        let matches = regex.getMatches(in: $0)
        return Ingredient(name: matches[0],
                          capacity: Int(matches[1])!,
                          durability: Int(matches[2])!,
                          flavour: Int(matches[3])!,
                          texture: Int(matches[4])!,
                          calories: Int(matches[5])!)
    })

    var combos: [[Int]] = []
    for i in 1...97 {
        for j in 1...97 where i + j < 99 {
            for k in 1...97 where i + j + k < 100 {
                for l in 1...97 where i + j + k + l == 100 {
                    combos.append([i, j, k, l])
                }
            }
        }
    }

    var maxScore = Int.min
    for c in combos {
        let capacity = max((0..<input.count).map({ ingredients[$0].capacity * c[$0] }).sum(), 0)
        let durability = max((0..<input.count).map({ ingredients[$0].durability * c[$0] }).sum(), 0)
        let flavour = max((0..<input.count).map({ ingredients[$0].flavour * c[$0] }).sum(), 0)
        let texture = max((0..<input.count).map({ ingredients[$0].texture * c[$0] }).sum(), 0)
        let calories = max((0..<input.count).map({ ingredients[$0].calories * c[$0] }).sum(), 0)
        if calories == 500 {
            maxScore = max(maxScore, capacity * durability * flavour * texture)
        }
    }

    print(maxScore)
}

struct Ingredient {
    let name: String

    let capacity: Int
    let durability: Int
    let flavour: Int
    let texture: Int
    let calories: Int
}

Timer.time(main)
