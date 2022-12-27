import Foundation

struct Disk {
    let positions: Int
    var currentPosition: Int
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var disks = input.map {
        let regex = Regex("(\\d+)")
        let matches = regex.getGreedyMatches(in: $0).compactMap(Int.init)
        return Disk(positions: matches[1], currentPosition: matches[3])
    }
    print(disks)

    disks.append(Disk(positions: 11, currentPosition: 0))
    var time = 0
    repeat { time += 1 } while !disksAreAligned(disks, time: time)
    print(time)
}

private func disksAreAligned(_ disks: [Disk], time: Int) -> Bool {
    for i in 1..<disks.count + 1 {
        let d = disks[i-1]
        if (d.currentPosition + time + i) % d.positions != 0 {
            return false
        }
    }
    return true
}

Timer.time(main)
