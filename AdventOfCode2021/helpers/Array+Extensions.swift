extension ArraySlice where Element == Int {
    func sum() -> Int {
        self.reduce(0, +)
    }

    func multiply() -> Int {
        self.reduce(1, *)
    }
}

extension Array where Element == Int {
    func sum() -> Int {
        self.reduce(0, +)
    }

    func multiply() -> Int {
        self.reduce(1, *)
    }
}

extension Array where Element: Equatable {
    func combinations(count: Int) -> [[Element]] {
        if count == 0 { return [[]] }

        if count == 1 { return self.map({ [$0] }) }

        let previousCombinations = combinations(count: count - 1)

        var combinations: [[Element]] = []

        for i in (0..<count) {
            for j in (0..<previousCombinations.count) where !previousCombinations[j].contains(self[i]) {
                combinations.append(previousCombinations[j] + [self[i]])
            }
        }

        return combinations
    }
}

extension Array where Element: Hashable {
    var counts: [Element: Int] {
        reduce(into: [:], { $0[$1] = ($0[$1] ?? 0) + 1 })
    }
}
