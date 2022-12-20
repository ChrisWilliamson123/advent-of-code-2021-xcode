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
    var index: Int
    let uuid = UUID()

    var description: String {
        "\(value), next: \(next.value), prev: \(prev.value)"
    }

    init(value: Int, index: Int) {
        self.value = value
        self.index = index
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let nodes = input.enumerated().map({ (index, number) in Node(value: Int(number)! * 811589153, index: index) })
    let count = nodes.count
    var initialIndexes = [Int: Node]()
    for nodeIndex in 0..<nodes.count {
        let prev = nodeIndex - 1 >= 0 ? nodeIndex - 1 : nodes.count - 1
        let next = nodeIndex + 1 < nodes.count ? nodeIndex + 1 : 0
        let node = nodes[nodeIndex]
        node.next = nodes[next]
        node.prev = nodes[prev]
        initialIndexes[nodeIndex] = node
    }
    for _ in 0..<10 {
        for nodeIndex in 0..<count {
            if nodeIndex % 1000 == 0 {
                print(nodeIndex)
            }
            let nodeToMove = initialIndexes[nodeIndex]!
            let amountToMove = nodeToMove.value
            let adjAmountToMove = amountToMove % (count - 1 )

            if adjAmountToMove > 0 {
                for _ in 0..<adjAmountToMove {
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
            } else if adjAmountToMove < 0 {
                for _ in 0..<abs(adjAmountToMove) {
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
        all.append(current.value)
        seen.insert(current)
        current = current.next!
    }

    print(all)
}

Timer.time(main)
