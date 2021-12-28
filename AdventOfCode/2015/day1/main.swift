import Foundation

func main() throws {
    let input: String = try readInput(fromTestFile: false)[0]
    var floor = 0
    var basementHit = false
    for i in 0..<input.count {
        let char: Character = input[i]
        floor += char == "(" ? 1 : -1

        if !basementHit && floor < 0 {
            print("Part two:", i+1)
            basementHit = true
        }
    }

    print("Part one:", floor)
}

try main()
