extension StringProtocol {
    var asciiValues: [Int] { compactMap(\.asciiValue).map { Int($0) } }
    var asciiValue: Int { asciiValues.first! }
    var asciiNormalised: Int {
        let ascii = asciiValue
        if self.first!.isUppercase {
            return ascii - 38
        }
        return ascii - 96
    }
}
