import Foundation

func main() throws {
    var latest: [Character] = "01111010110010011".compactMap(Character.init)
    let diskLength = 35651584
    while latest.count < diskLength {
        latest = latest.dragonCurve
    }
    let full = Array(latest[0..<diskLength])
    var checksum = full.checksum
    while checksum.count % 2 == 0 {
        checksum = checksum.checksum
    }
    print(checksum.compactMap(String.init).joined())
}

private extension [Character] {
    var dragonCurve: [Character] {
        var b = self.reversed().map(Character.init)
        for i in 0..<b.count {
            if b[i] == "1" { b[i] = "0" }
            else { b[i] = "1" }
        }
        return self + ["0"] + b
    }

    var checksum: [Character] {
        var checksum: [Character] = []
        for i in stride(from: 1, through: count - 1, by: 2) {
            let prev = self[i-1]
            let cur = self[i]
            if prev == cur {
                checksum.append("1")
            } else {
                checksum.append("0")
            }
        }
        return checksum
    }
}

Timer.time(main)
