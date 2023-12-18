import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    assert(input.count == 3, "input has too many sections.")
    let fields: [String: Set<Int>] = input[0].split(separator: "\n").map({decodeField(String($0))}).reduce(into: [:], { $0[$1.name] = $1.validValues })
    let yourTicket = input[1].split(separator: "\n")[1].split(separator: ",").map({Int($0)!})
    let nearbyTickets = input[2].split(separator: "\n").suffix(from: 1)

    var errorRate = 0
    let allValidValues: Set<Int> = fields.values.reduce([], { $0.union($1) })

    let validNearbyTickets = nearbyTickets.filter({ ticket in
        let values = ticket.split(separator: ",").map({Int($0)!})
        for v in values {
            if !allValidValues.contains(v) {
                errorRate += v
                return false
            }
        }
        return true
    }).map({ $0.split(separator: ",").map({ Int($0)! }) })

    print("Part 1:", errorRate)

    /// PART TWO

    let fieldCount = fields.count

    var fieldsList: [String?] = Array(repeating: nil, count: fieldCount)
    while fieldsList.firstIndex(of: nil) != nil {
        for i in 0..<fieldCount where fieldsList[i] == nil {
            var possibleFields: Set<String> = Set(fields.keys.filter({ !fieldsList.contains($0) }))

            for p in possibleFields {
                for v in validNearbyTickets {
                    let fieldValue = v[i]
                    if !fields[p]!.contains(fieldValue) {
                        possibleFields.remove(p)
                    }
                }
            }

            if possibleFields.count == 1 {
                fieldsList[i] = Array(possibleFields)[0]
            }
        }
    }

    var departureFieldIndexes: [Int] = []
    fieldsList.enumerated().forEach { (index, item) in
        if item!.contains("departure") {
            departureFieldIndexes.append(index)
        }
    }

    print("Part 2:", departureFieldIndexes.map({ yourTicket[$0] }).multiply())

}

private func decodeField(_ input: String) -> Field {
    let nameSplit = input.components(separatedBy: ": ")
    let fieldName = nameSplit[0]

    let valueSplits = nameSplit[1].components(separatedBy: " or ")
    var values: Set<Int> = []
    for v in valueSplits {
        let lower = Int(v.split(separator: "-")[0])!
        let upper = Int(v.split(separator: "-")[1])!
        (lower...upper).forEach({ values.insert($0) })
    }

    return .init(name: fieldName, validValues: values)
}

struct Field {
    let name: String
    let validValues: Set<Int>
}

Timer.time(main)
