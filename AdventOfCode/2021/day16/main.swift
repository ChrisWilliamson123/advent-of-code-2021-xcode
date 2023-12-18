import Foundation

func main() throws {
    let input: String = try readInput(fromTestFile: false)[0]

    let transmission = input.hexaToBinary

    let result = readPacket(transmission).packets[0]
    let versionNumberSum = getAllVersionNumbers(result).sum()

    print("Part 1:", versionNumberSum)
    print("Part 2:", result.value)
}

private func getAllVersionNumbers(_ root: PacketResult) -> [Int] {
    if root.subPackets.isEmpty { return [root.version] }

    var results: [Int] = [root.version]

    root.subPackets.forEach({ results.append(contentsOf: getAllVersionNumbers($0)) })

    return results
}

private func readPacket(_ packet: String, limit: Int? = nil) -> (packets: [PacketResult], end: Int) {
    var packets: [PacketResult] = []
    var index = 0

    while index < packet.count && (packet.count - index > 10) && packets.count < (limit ?? Int.max) {
        let packetVersion = getDecimal(from: packet[index..<index+3])
        let typeID = getDecimal(from: packet[index+3..<index+6])
        index += 6

        if typeID == 4 {
            let literalValueResult = decodeLiteralValue(packet[index..<packet.count])
            index += literalValueResult.length
            packets.append(.init(version: packetVersion, typeID: typeID, value: literalValueResult.literalValue, subPackets: []))
        } else {
            let lengthTypeID: String = packet[index]
            index += 1
            if lengthTypeID == "0" {
                /// Next 15 bits are a number that represents the total length in bits of the sub-packets contained by this packet
                let subPacketsTotalLength = getDecimal(from: packet[index..<index+15])
                index += 15
                let subPacketsTotalString = packet[index..<index+subPacketsTotalLength]
                let packet = readPacket(subPacketsTotalString).packets
                packets.append(.init(version: packetVersion,
                                     typeID: typeID,
                                     value: getPacketValue(subPackets: packet, id: typeID),
                                     subPackets: packet))
                index += subPacketsTotalLength
            } else {
                /// Next 11 bits are a number that represents the number of sub-packets immediately contained by this packet.
                let numberOfSubpackets = getDecimal(from: packet[index..<index+11])
                index += 11
                let subPacketsString = packet[index..<packet.count]
                let packet = readPacket(subPacketsString, limit: numberOfSubpackets)
                packets.append(.init(version: packetVersion,
                                     typeID: typeID,
                                     value: getPacketValue(subPackets: packet.packets, id: typeID),
                                     subPackets: packet.packets))
                index += packet.end
            }
        }
    }

    return (packets, index)
}

private func getPacketValue(subPackets: [PacketResult], id: Int) -> Int {
    switch id {
    case 0: return subPackets.map({ $0.value }).sum()
    case 1: return subPackets.map({ $0.value }).multiply()
    case 2: return subPackets.map({ $0.value }).min()!
    case 3: return subPackets.map({ $0.value }).max()!
    case 5: return subPackets[0].value > subPackets[1].value ? 1 : 0
    case 6: return subPackets[0].value < subPackets[1].value ? 1 : 0
    case 7: return subPackets[0].value == subPackets[1].value ? 1 : 0
    default: assert(false)
    }
}

private struct PacketResult {
    let version: Int
    let typeID: Int
    let value: Int
    let subPackets: [PacketResult]
}

private func decodeLiteralValue(_ input: String) -> (literalValue: Int, length: Int) {
    var binaryString = ""
    var end = 0
    for i in stride(from: 0, to: input.count-1, by: 5) {
        let bits = input[i..<i+5]
        binaryString += bits[1..<5]

        if bits[0] == "0" {
            end = i + 5
            break
        }
    }
    return (getDecimal(from: binaryString), end)
}

private func getDecimal(from binaryString: String) -> Int {
    Int(binaryString, radix: 2)!
}

private extension String {
    typealias Byte = UInt8

    var hexaToBytes: [Byte] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let end = index(after: start)
            defer { start = index(after: end) }
            return Byte(self[start...end], radix: 16)
        }
    }

    var hexaToBinary: String {
        hexaToBytes.map {
            let binary = String($0, radix: 2)
            return repeatElement("0", count: 8-binary.count) + binary
        }.joined()
    }
}

Timer.time(main)
