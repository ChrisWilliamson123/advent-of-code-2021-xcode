import Foundation
import CryptoKit

func main() throws {
    let input = "ihaygndm"
    var index = 0
    var otpKeyIndexes: [Int] = []

    let queue = OperationQueue()
    var hashDicts: [[Int: String]] = []
    let threadSize = 5000
    for i in stride(from: 0, to: 50000, by: threadSize) {
        queue.addOperation({
            var hashes: [Int: String] = [:]
            for j in i..<i+threadSize {
                var hash = MD5(string: "\(input)\(j)")
                for _ in 0..<2016 { hash = MD5(string: hash) }
                hashes[j] = hash
            }
            hashDicts.append(hashes)
        })
    }
    queue.waitUntilAllOperationsAreFinished()
    let hashes = hashDicts.reduce(into: [Int: String](), { $0.merge($1, uniquingKeysWith: { $1 }) })
    while otpKeyIndexes.count < 64 {
        let hash = hashes[index]!
        if let triple = hash.triple() {
            for i in index+1...index+1000 {
                let hash = hashes[i]!
                let pent = "\(triple)\(triple)\(triple)\(triple)\(triple)"
                if hash.contains(pent) {
                    otpKeyIndexes.append(index)
                    break
                }
            }
        }
        index += 1
    }

    print(otpKeyIndexes[otpKeyIndexes.count-1])
}

private extension String {
    func triple() -> String? {
        for i in 2..<self.count {
            if Set([self[i-2], self[i-1], self[i]]).count == 1 {
                return self[i]
            }
        }
        return  nil
    }
}

func MD5(string: String) -> String {
    Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data()).description[12..<44]
}

Timer.time(main)
