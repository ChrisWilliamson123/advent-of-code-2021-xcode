import Foundation

enum Axis3D {
    case x
    case y
    case z
}

struct Coordinate3D: Hashable {
    let x: Int
    let y: Int
    let z: Int

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct Brick: Hashable, CustomStringConvertible {
    let start: Coordinate3D
    let end: Coordinate3D

    let id: Int
    typealias CoveredCoordinates = (x: Range<Int>, y: Range<Int>, z: Range<Int>)
    var coveredCoordinates: CoveredCoordinates {
        let x = min(start.x, end.x)..<max(start.x, end.x)+1
        let y = min(start.y, end.y)..<max(start.y, end.y)+1
        let z = min(start.z, end.z)..<max(start.z, end.z)+1
        return (x, y, z)
    }

    var description: String {
        "\(start.x),\(start.y),\(start.z)~\(end.x),\(end.y),\(end.z) <- \(id)"
    }

    var height: Int {
        (max(start.z, end.z) - min(start.z, end.z)) + 1
    }
}

private func fallBricks(bricks: [Brick]) -> Int {
    let sortedZ = bricks.sorted(by: { $0.start.z < $1.start.z })

    var fallen = sortedZ.filter({ $0.start.z == 1 })

    var fallenCount = 0

    for brick in sortedZ where brick.start.z > 1 {
        // Find the highest brick that intersects this bricks x/y coords
        if let highest = fallen
            .filter({ $0.coveredCoordinates.x.overlaps(brick.coveredCoordinates.x) && $0.coveredCoordinates.y.overlaps(brick.coveredCoordinates.y) && $0.end.z < brick.start.z })
            .sorted(by: { $0.end.z > $1.end.z }).first {
            let new = Brick(start: Coordinate3D(brick.start.x, brick.start.y, highest.end.z + 1), end: Coordinate3D(brick.end.x, brick.end.y, highest.end.z + brick.height), id: brick.id)
            if new != brick {
                fallenCount += 1
            }
            fallen.append(new)
        } else {
            // There's no intersecting bricks, so send down to floor
            fallen.append(.init(start: Coordinate3D(brick.start.x, brick.start.y, 1), end: Coordinate3D(brick.end.x, brick.end.y, brick.height), id: brick.id))
            fallenCount += 1
        }
    }

    return fallenCount
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    let bricks = input.enumerated().map({ (index, line) in
        let split = line.split(separator: "~")
        let lhs = split[0].split(separator: ",").map({ Int($0)! })
        let rhs = split[1].split(separator: ",").map({ Int($0)! })
        assert(lhs[2] <= rhs[2], "fail!")
        return Brick(start: Coordinate3D(lhs[0], lhs[1], lhs[2]), end: Coordinate3D(rhs[0], rhs[1], rhs[2]), id: index + 1)
    })

    let sortedZ = bricks.sorted(by: { $0.start.z < $1.start.z })

    var fallen = sortedZ.filter({ $0.start.z == 1 })

    for brick in sortedZ where brick.start.z > 1 {

        // Find the highest brick that intersects this bricks x/y coords
        if let highest = fallen
            .filter({ $0.coveredCoordinates.x.overlaps(brick.coveredCoordinates.x) && $0.coveredCoordinates.y.overlaps(brick.coveredCoordinates.y) })
            .sorted(by: { $0.end.z > $1.end.z }).first {
            fallen.append(.init(start: Coordinate3D(brick.start.x, brick.start.y, highest.end.z + 1), end: Coordinate3D(brick.end.x, brick.end.y, highest.end.z + brick.height), id: brick.id))
        } else {
            // There's no intersecting bricks, so send down to floor
            fallen.append(.init(start: Coordinate3D(brick.start.x, brick.start.y, 1), end: Coordinate3D(brick.end.x, brick.end.y, brick.height), id: brick.id))
        }
    }
    assert(fallen.count == sortedZ.count)

    // Find pairs
    var supporters: [Brick: Set<Brick>] = [:]
    // For bricks that are not attached to ground
    for brick in fallen.filter({ $0.start.z > 1 }) {
        let bricksBelow = fallen.filter({ $0.end.z == brick.start.z - 1 })
        let intersecting = bricksBelow.filter({ $0.coveredCoordinates.x.overlaps(brick.coveredCoordinates.x) && $0.coveredCoordinates.y.overlaps(brick.coveredCoordinates.y) })
        if !intersecting.isEmpty {
            supporters[brick] = Set(intersecting)
        }
    }

    let bricksNotSupportingAnything: Set<Brick> = fallen.reduce(into: [], { partial, brick in
        let intersecting = fallen.filter({ $0.coveredCoordinates.x.overlaps(brick.coveredCoordinates.x) && $0.coveredCoordinates.y.overlaps(brick.coveredCoordinates.y) })
        let higher = intersecting.filter({ $0.start.z == brick.end.z + 1 })
        if higher.isEmpty {
            partial.insert(brick)
        }
    })

    for (key, value) in supporters.sorted(by: { $0.key.end.z < $1.key.end.z }) {
        print(key, value)
    }

    var canBeRemoved: Set<Brick> = []

    for (_, value) in supporters where value.count > 1 {
        canBeRemoved = canBeRemoved.union(value)
    }

    canBeRemoved = canBeRemoved.filter({ brick in !supporters.contains(where: { $0.value.contains(brick) && $0.value.count == 1 }) })
    print(canBeRemoved.count + bricksNotSupportingAnything.count)

    var tot = 0
    for i in 0..<fallen.count {
        var new = fallen
        let removed = new.remove(at: i)
        tot += fallBricks(bricks: new)
    }
    print(tot)
}

Timer.time(main)
