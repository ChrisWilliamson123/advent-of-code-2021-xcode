import Foundation

struct Card {
    let id: Int
    let winningNumbers: Set<Int>
    let givenNumbers: Set<Int>
    var copies: Int = 1
    
    var matchCount: Int {
        winningNumbers.intersection(givenNumbers).count
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    
    let cards = input.map { line in
        let split1 = line.split(separator: ": ")
        let id = Int(split1[0].split(separator: " ")[1])!
        let numbersSplit = split1[1].split(separator: " | ")
        let winningNumbers = numbersSplit[0].split(separator: " ").reduce(into: Set<Int>(), { $0.insert(Int($1)!) })
        let givenNumbers = numbersSplit[1].split(separator: " ").reduce(into: Set<Int>(), { $0.insert(Int($1)!) })
        return Card(id: id, winningNumbers: winningNumbers, givenNumbers: givenNumbers)
    }
    
    let part1 = cards.reduce(0, {
        let matches = $1.matchCount
        if matches > 0 {
            return $0 + Int(pow(2, Double(matches - 1)))
        } else {
            return $0
        }
    })
    print(part1)
    
    var mutableCards = cards
    for index in mutableCards.indices {
        let c = mutableCards[index]
        let matches = c.matchCount
        for copyIndex in index+1..<index+1+matches {
            mutableCards[copyIndex].copies += c.copies
        }
    }
    
    print(mutableCards.reduce(0, { $0 + $1.copies }))
}

Timer.time(main)
