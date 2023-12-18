import Foundation

private func getColumn(_ grid: [[Character]], index: Int) -> [Character] {
    grid.map { $0[index] }
}

private func getReflection(rows: [[Character]]) -> Int? {
    for i in 0..<rows.count-1 {
        let topLength = i + 1
        let bottomLength = rows.count - topLength
        let smallestLength = min(topLength, bottomLength)

        let topSlice = rows[max(0, i - smallestLength + 1)...i]
        let bottomSlice = rows[i+1...i+smallestLength]
        assert(topSlice.count == bottomSlice.count)

        let reversedBottom = Array(bottomSlice.reversed())
        let reversedBottomFlat = reversedBottom.flatMap({ $0 })
        let topSliceFlat = topSlice.flatMap({ $0 })
        let diff = topSliceFlat.indices.filter({ reversedBottomFlat[$0] != topSliceFlat[$0] })
        print("Diff count: \(diff.count)")
        if diff.count == 1 {
            return topLength
        }

//        if Array(topSlice) == reversedBottom {
//            return topLength
//        }
    }
    return nil
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n\n")
    var total = 0

    for valleyMap in input {
        let grid = valleyMap.split(separator: "\n").map({ [Character]($0) })

        let horizontal = getReflection(rows: grid)
        let vertical = getReflection(rows: grid.rotatedRight())

//        print(horizontal, vertical)

        total += (horizontal ?? 0) * 100
        total += vertical ?? 0
    }

    print(total)
}

Timer.time(main)

private extension Array where Element: Collection, Element.Index == Int {
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
