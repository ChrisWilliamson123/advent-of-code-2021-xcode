import Foundation
import CryptoKit

func main() throws {
    let input = "udskfozm"
    let start = Coordinate(0, 0)
    let end = Coordinate(3, 3)
    let hash = getHash(input: input, path: "")

    struct Explored: Hashable {
        let pos: Coordinate
        let path: String
    }
    func bfs(start: Coordinate, target: Coordinate) -> String {
        var frontier: [(start: Coordinate, distance: Int, path: String)] = [(start, 0, "")]
        var explored: Set<Explored> = [.init(pos: start, path: "")]
        while !frontier.isEmpty {
            let (pos, dis, path) = frontier.popLast()!
            let hash = getHash(input: input, path: path)
            let doorStatusses = getDoorStatuses(from: hash)
            let axials = [(Direction.up, Coordinate(0, -1) + pos), (Direction.down, Coordinate(0, 1) + pos), (Direction.left, Coordinate(-1, 0) + pos), (Direction.right, Coordinate(1, 0) + pos)]
                .filter({ (0...3).contains($0.1.x) && (0...3).contains($0.1.y) }).filter({ axial in doorStatusses.first(where: { $0.1 == axial.0 })!.0 })
            for a in axials {
                if a.1 == target { return path + a.0.rawValue }
                let ex = Explored(pos: a.1, path: path + a.0.rawValue)
                if !explored.contains(ex) {
                    frontier.insert((a.1, dis + 1, path + a.0.rawValue), at: 0)
                    explored.insert(ex)
                }
            }
        }
        assert(false)
    }

    func dfs(start: Coordinate, target: Coordinate, distance: Int, path: String) -> Int {
        if start == target {
            return distance
        }
        let hash = getHash(input: input, path: path)
        let doorStatusses = getDoorStatuses(from: hash)
        let axials = [(Direction.up, Coordinate(0, -1) + start), (Direction.down, Coordinate(0, 1) + start), (Direction.left, Coordinate(-1, 0) + start), (Direction.right, Coordinate(1, 0) + start)]
            .filter({ (0...3).contains($0.1.x) && (0...3).contains($0.1.y) }).filter({ axial in doorStatusses.first(where: { $0.1 == axial.0 })!.0 })
        if axials.count == 0 {
            return -1
        }
        var best = 0
        for a in axials {
            let result = dfs(start: a.1, target: target, distance: distance + 1, path: path + a.0.rawValue)
            best = max(best, result)
        }
        return best
    }
    print(bfs(start: start, target: end))
    print(dfs(start: start, target: end, distance: 0, path: ""))
}

enum Direction: String, CaseIterable {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

private func getDoorStatuses(from hash: String) -> Zip2Sequence<[Bool], [Direction]> {
    zip(hash[0..<4].map({ ["b", "c", "d", "e", "f"].contains($0) }), Direction.allCases)
}

private func getHash(input: String, path: String) -> String {
    Insecure.MD5.hash(data: "\(input)\(path)".data(using: .utf8) ?? Data()).description[12..<44]
}

Timer.time(main)
