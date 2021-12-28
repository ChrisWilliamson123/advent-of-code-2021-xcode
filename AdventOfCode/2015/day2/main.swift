import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let presents = input.map({ Present($0) })
    let paperNeeded = presents.map({ $0.surfaceArea + $0.smallestSide }).sum()
    print("Part one:", paperNeeded)

    let ribbonNeeded = presents.map({ $0.ribbonRequired + $0.bowRibbonNeeded }).sum()
    print("Part two:", ribbonNeeded)
}

struct Present {
    let length: Int
    let width: Int
    let height: Int

    var surfaceArea: Int { (2*length*width) + (2*width*height) + (2*height*length) }
    var smallestSide: Int { [length, width, height].sorted()[0...1].multiply() }
    var ribbonRequired: Int { [length, width, height].sorted()[0...1].sum() * 2 }
    var bowRibbonNeeded: Int { length * width * height }

    init(_ presentString: String) {
        let regex = Regex("(\\d+)x(\\d+)x(\\d+)")
        let matches = regex.getMatches(in: presentString)
        self.length = Int(matches[0])!
        self.width = Int(matches[1])!
        self.height = Int(matches[2])!
    }
}

try main()
