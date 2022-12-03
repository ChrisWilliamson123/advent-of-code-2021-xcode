extension StringProtocol {
    var asciiValues: [Int] { compactMap(\.asciiValue).map { Int($0) } }
    var asciiValue: Int { asciiValues.first! }
}
