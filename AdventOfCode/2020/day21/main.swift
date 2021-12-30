import Foundation

func main() throws {
    let foods: [String] = try readInput(fromTestFile: false)

    var allergensToPotentialIngredients: [String: Set<String>] = [:]
    var allIngredients: Set<String> = []
    var allIngredientsCounts: [String: Int] = [:]

    for f in foods {
        let regex = Regex("(.*) \\(contains (.*)\\)")
        let matches = regex.getMatches(in: f)
        let ingredients = matches[0].split(separator: " ").map({ String($0) })
        let allergens = matches[1].components(separatedBy: ", ")
        for a in allergens {
            if let current = allergensToPotentialIngredients[String(a)] {
                allergensToPotentialIngredients[String(a)] = current.intersection(Set(ingredients))
            } else {
                allergensToPotentialIngredients[String(a)] = Set(ingredients)
            }
        }

        allIngredients = allIngredients.union(Set(ingredients))
        for i in ingredients {
            allIngredientsCounts[i] = allIngredientsCounts[i, default: 0] + 1
        }
    }

    let allergenedIngredients: Set<String> = allergensToPotentialIngredients.reduce([], { $0.union($1.value) })
    let nonAllergenedIngredients = allIngredients.subtracting(allergenedIngredients)

    print("Part one:", nonAllergenedIngredients.map({ allIngredientsCounts[$0]! }).sum())

    var done: Set<String> = []
    while done.count != allergensToPotentialIngredients.count {
        let allergenWithOneIngredient = allergensToPotentialIngredients.first(where: { $0.value.count == 1 && !done.contains($0.key) })!
        for (k, v) in allergensToPotentialIngredients where k != allergenWithOneIngredient.key {
            allergensToPotentialIngredients[k] = v.subtracting([allergenWithOneIngredient.value.first!])
        }
        done.insert(allergenWithOneIngredient.key)
    }

    print("Part two:", allergensToPotentialIngredients.sorted(by: { $0.key < $1.key }).map({ $0.value.first! }).joined(separator: ","))
}

try main()

