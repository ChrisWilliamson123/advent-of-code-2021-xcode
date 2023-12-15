import Foundation

private func getHashValue(_ input: String) -> Int {
    var current: Int = 0
    for c in input {
        let asciiCode = c.asciiValue!
        current += Int(asciiCode)
        current *= 17
        current %= 256
    }
    
    return current
}

struct Instruction {
    enum Operation: CustomStringConvertible {
        case remove
        case replace(Int)
        
        var description: String {
            switch self {
            case .remove:
                return "remove"
            case .replace(let int):
                return "replace \(int)"
            }
        }
    }
    let id: String
    let operation: Operation
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let initialisationSequence = input[0].split(separator: ",")
    let part1 = initialisationSequence.reduce(0, { $0 + getHashValue(String($1)) })
    print(part1)
    
    /*
     Part 2
     256 boxes in total
     letters = label of lens on which to operate
     hash result = box used for step
     operator sign (=, -)
        -: remove lens from box, move other lenses in box forward as fas as they can go
        =(followed by focal length): replace old lens with same label with new lens or add lens to box at end
     */
    let instructions = initialisationSequence.map({
        let regex = Regex("(\\w+)(-|=)(\\d+)?")
        let matches = regex.getMatches(in: String($0))
        let operation: Instruction.Operation = matches.count == 3 ? .replace(Int(matches[2])!) : .remove
        return Instruction(id: matches[0], operation: operation)
    })
        
    typealias Lens = (id: String, focalLength: Int)
    var boxes: [Int: [Lens]] = [:]
    
    instructions.forEach({ instruction in
        let boxId = getHashValue(instruction.id)
        let lensId = instruction.id
        switch instruction.operation {
        case .remove:
            boxes[boxId] = boxes[boxId]?.filter({ $0.id != lensId }) ?? [] // nil case will add an empty key/value but that isn't really a problem
        case .replace(let newFocalLength):
            if var lensesInBox = boxes[boxId] {
                if let existingLensIndex = lensesInBox.firstIndex(where: { $0.id == lensId }) {
                    lensesInBox[existingLensIndex] = (lensId, newFocalLength)
                } else {
                    lensesInBox.append((lensId, newFocalLength))
                }
                boxes[boxId] = lensesInBox
            } else {
                boxes[boxId] = [(lensId, newFocalLength)]
            }
        }
    })
    
    var focussingPower = 0
    for (boxId, lenses) in boxes {
        for (i, l) in lenses.enumerated() {
            focussingPower += (1 + boxId) * (i + 1) * l.focalLength
        }
    }
    
    print(focussingPower)
}

Timer.time(main)
