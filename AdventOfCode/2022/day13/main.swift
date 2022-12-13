import Foundation

enum Packet: Comparable, Decodable {
    case value(Int)
    indirect case list([Packet])

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self = .value(try container.decode(Int.self))
        } catch {
            self = .list(try [Packet](from: decoder))
        }
    }

    static func <(_ lhs: Packet, _ rhs: Packet) -> Bool {
        switch (lhs, rhs) {
        case (.value(let value1), .value(let value2)):
            return value1 < value2
        case (.value, .list):
            return Packet.list([lhs]) < rhs
        case (.list, .value):
            return lhs < Packet.list([rhs])
        case (.list(let list1), .list(let list2)):
            for i in 0..<min(list1.count, list2.count) {
                if list1[i] == list2[i] { continue }
                return list1[i] < list2[i]
            }
            return list1.count <= list2.count
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let decoder = JSONDecoder()
    var sum = 0
    var allPackets: [Packet] = []
    for (index, packetPair) in input.enumerated() {
        let pair = packetPair.components(separatedBy: "\n")[0..<2].map {
            let data = $0.data(using: .utf8)!
            return try! decoder.decode(Packet.self, from: data)
        }
        allPackets.append(contentsOf: pair)
        if pair[0] < pair[1] {
            sum += index + 1
        }
    }
    print(sum)

    let two = Packet.list([Packet.list([Packet.value(2)])])
    let six = Packet.list([Packet.list([Packet.value(6)])])
    allPackets.append(contentsOf: [two, six])
    let sorted = allPackets.sorted()
    print((sorted.firstIndex(of: two)!+1) * (sorted.firstIndex(of: six)!+1))

}

Timer.time(main)
