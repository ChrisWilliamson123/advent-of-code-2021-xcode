import Foundation

func getDifferenceSequence(_ input: [Int]) -> [Int] {
    (1..<input.count).map({ input[$0] - input[$0 - 1] })
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    var sequences = input.map({ $0.split(separator: " ").compactMap({ Int($0) }) })
//    print(sequences)
    
    for j in 0..<sequences.count {
        var differences = [sequences[j], getDifferenceSequence(sequences[j])]
        while differences.last!.contains(where: { $0 != 0 }) {
            differences.append(getDifferenceSequence(differences.last!))
        }
        
        print(differences)
        for i in stride(from: differences.count-2, through: 0, by: -1) {
//            differences[i].append(differences[i].last! + differences[i+1].last!)
            differences[i].insert(differences[i].first! - differences[i+1].first!, at: 0)
        }
        print(differences)
        sequences[j] = differences[0]
        print("\n\n")
    }
//    print(sequences)
    print(sequences.map({ $0.first! }).sum())
    
}

Timer.time(main)
