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

extension Array where Element == UInt8 {
    func sum() -> UInt8 {
        self.reduce(0, +)
    }

    func multiply() -> UInt8 {
        self.reduce(1, *)
    }
}

extension Array where Element == UInt16 {
    func sum() -> UInt16 {
        self.reduce(0, +)
    }

    func multiply() -> UInt16 {
        self.reduce(1, *)
    }
}

extension Array where Element: Hashable {
    var counts: [Element: Int] {
        reduce(into: [:], { $0[$1] = $0[$1, default: 0] + 1 })
    }
}

extension Array where Element: Collection, Element.Index == Int {
    func rotatedRight() -> [[Element.Iterator.Element]] {

        typealias InnerElement = Element.Iterator.Element
        
        // in the case of an empty array, simply return an empty array
        if self.isEmpty { return [] }
        let length = self[0].count
        
        return (0..<length).map { index in
            self.map({ $0[index] }).reversed()
        }
    }
}
