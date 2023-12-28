import Foundation

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

struct Hail: CustomStringConvertible {
    let startCoord: Coordinate3D
    let velocity: Coordinate3D

    var gradient: Double {
        Double(velocity.y) / Double(velocity.x)
    }

    var constant: Double {
        // y - mx
        Double(startCoord.y) - (gradient * Double(startCoord.x))
    }

    var description: String {
        // 19, 13, 30 @ -2, 1, -2
        "\(startCoord.x), \(startCoord.y), \(startCoord.z) @ \(velocity.x), \(velocity.y), \(velocity.z)"
    }

    func isInFuture(_ point: (Double, Double)) -> Bool {
        let xNeg = velocity.x < 0
        let yNeg = velocity.y < 0

        let xCorrect = xNeg && point.0 < Double(startCoord.x) || !xNeg && point.0 > Double(startCoord.x) || velocity.x == 0 && point.0 == Double(startCoord.x)
        let yCorrect = yNeg && point.1 < Double(startCoord.y) || !yNeg && point.1 > Double(startCoord.y) || velocity.y == 0 && point.1 == Double(startCoord.y)

        return xCorrect && yCorrect


    }
}

private func getIntersection(hail1: Hail, hail2: Hail) -> (x: Double, y: Double) {
    let x = (hail2.constant - hail1.constant) / (hail1.gradient - hail2.gradient)
    let y = (hail1.gradient * x) + hail1.constant

    return (x, y)
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")

    let hailstones: [Hail] = input.map({
        let numbers = Regex("(-?\\d+)").getGreedyMatches(in: $0).compactMap({ Int($0) })
        return Hail(startCoord: .init(numbers[0], numbers[1], numbers[2]), velocity: .init(numbers[3], numbers[4], numbers[5]))
    })

    let low: Double = 200000000000000
//    let low: Double = 7
    let high: Double = 400000000000000
//    let high: Double = 27

    var collided: Set<Int> = []

    var inside = 0
    for i in 0..<hailstones.count - 1 {
        for j in i+1..<hailstones.count {
            let inter = getIntersection(hail1: hailstones[i], hail2: hailstones[j])

            if inter.x == Double.infinity || inter.y == Double.infinity {
                continue
            }
//            print(hailstones[i])
//            print(hailstones[j])
//            print(inter)

            if inter.x >= low && inter.x <= high && inter.y >= low && inter.y <= high && hailstones[i].isInFuture(inter) && hailstones[j].isInFuture(inter) {
//                print("adding")
                inside += 1
//                collided.insert(i)
//                collided.insert(j)
            }
        }
    }

    print(inside)

}

Timer.time(main)
