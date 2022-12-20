import Foundation

class Node: CustomStringConvertible, Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    let value: Int
    var next: Node!
    var prev: Node!
    let uuid = UUID()

    var description: String {
        "\(value), next: \(next.value), prev: \(prev.value)"
    }

    init(value: Int) {
        self.value = value
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let nodes = input.map({ Node(value: Int($0)!) })
    var initialIndexes = [Int: Node]()
    for nodeIndex in 0..<nodes.count {
        let prev = nodeIndex - 1 >= 0 ? nodeIndex - 1 : nodes.count - 1
        let next = nodeIndex + 1 < nodes.count ? nodeIndex + 1 : 0
        let node = nodes[nodeIndex]
        node.next = nodes[next]
        node.prev = nodes[prev]
        initialIndexes[nodeIndex] = node
    }

    for nodeIndex in 0..<nodes.count {
        if nodeIndex % 1000 == 0 {
            print(nodeIndex)
        }
        let nodeToMove = initialIndexes[nodeIndex]!
        let amountToMove = nodeToMove.value
        if amountToMove > 0 {
            for _ in 0..<amountToMove {
                let previousNode = nodeToMove.prev
                let nextNode = nodeToMove.next
                let twoNext = nextNode!.next

                nodeToMove.prev = nextNode
                nodeToMove.next = twoNext

                twoNext!.prev = nodeToMove

                previousNode!.next = nextNode

                nextNode!.prev = previousNode
                nextNode!.next = nodeToMove
            }
        } else if amountToMove < 0 {
            for _ in 0..<abs(amountToMove) {
                let previousNode = nodeToMove.prev
                let nextNode = nodeToMove.next

                let twoPrev = previousNode!.prev

                nodeToMove.next = previousNode
                nodeToMove.prev = twoPrev

                twoPrev!.next = nodeToMove

                nextNode!.prev = previousNode

                previousNode!.next = nextNode
                previousNode!.prev = nodeToMove
            }
        }
    }
    print("Done moving")
    var groves: [Int] = []
    var current = nodes.first(where: { $0.value == 0 })!
    for i in 0...3000 {
        if i % 1000 == 0 {
            groves.append(current.value)
        }
        current = current.next!
    }
    print(groves.sum())


}

private func printNodes(_ node: Node) {

    var all: [Int] = []
    var seen: Set<Node> = []
    var current = node
    while !seen.contains(current) {
//        print(seen.count)
        all.append(current.value)
//        print(all)
        seen.insert(current)
//        print(seen)
        current = current.next!
//        print(current)
    }

    print(all)
}

Timer.time(main)
