import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let stream = input[0]

    let part1 = getIndexOfFirstUniqueChars(length: 4, stream: stream)
    print(part1)

    let part2 = getIndexOfFirstUniqueChars(length: 14, stream: stream)
    print(part2)
}

func getIndexOfFirstUniqueChars(length: Int, stream: String) -> Int {
    for i in length-1..<stream.count {
        let previous = stream[i-(length-1)...i]
        if Set(previous).count == length {
            return i + 1
        }
    }
    return -1
}

try main()
