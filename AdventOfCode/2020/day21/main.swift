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
            allIngredientsCounts[i] = (allIngredientsCounts[i] ?? 0) + 1
        }
    }

    print(allergensToPotentialIngredients)
    let allergenedIngredients: Set<String> = allergensToPotentialIngredients.reduce([], { $0.union($1.value) })
    let nonAllergenedIngredients = allIngredients.subtracting(allergenedIngredients)
    print(nonAllergenedIngredients)

    print(nonAllergenedIngredients.map({ allIngredientsCounts[$0]! }).sum())

//    let singleValueItem = ingredientsToPotentialAllergens.first(where: { $0.value.count == 1 })!
//    for (key, value) in ingredientsToPotentialAllergens where key != singleValueItem.key {
//        ingredientsToPotentialAllergens[key] = value.filter({ $0 != singleValueItem.value[0] })
//    }
//
//    print(ingredientsToPotentialAllergens)
}

try main()

