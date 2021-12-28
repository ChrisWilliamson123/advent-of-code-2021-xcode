class CrabCups {
    let valuesToNodes: [Int: Node]
    var currentNode: Node
    let minCupValue: Int
    let maxCupValue: Int

    init(cups: [Int]) {
        let currentNode = Node(value: cups[0])
        var prevNode: Node = currentNode
        var valuesToNodes: [Int: Node] = [currentNode.value: currentNode]
        self.minCupValue = cups.min()!
        self.maxCupValue = cups.max()!

        for i in cups[1..<cups.count] {
            let node = Node(value: i)
            valuesToNodes[i] = node
            prevNode.next = node
            prevNode = node
        }

        prevNode.next = currentNode
        self.currentNode = currentNode
        self.valuesToNodes = valuesToNodes
    }

    func executeMove() {
        let pickedCupNodes = [currentNode.next!, currentNode.next!.next!, currentNode.next!.next!.next!]
        let pickedCupValues = pickedCupNodes.map({ $0.value })

        currentNode.next = currentNode.next!.next!.next!.next!

        var destinationValue = currentNode.value - 1
        while pickedCupValues.contains(destinationValue) || valuesToNodes[destinationValue] == nil {
            destinationValue -= 1
            if destinationValue < minCupValue {
                destinationValue = maxCupValue
            }
        }
        let destinationNode = valuesToNodes[destinationValue]!

        pickedCupNodes.last!.next = destinationNode.next
        destinationNode.next = pickedCupNodes.first

        currentNode = currentNode.next!
    }

    func getOrder() -> String {
        var seen: Set<Int> = []
        var result = ""
        var currentNode = valuesToNodes[1]!.next!
        while !seen.contains(currentNode.value) && currentNode.value != valuesToNodes[1]!.value {
            result += "\(currentNode.value)"
            seen.insert(currentNode.value)
            currentNode = currentNode.next!
        }

        return result
    }
}

func main() throws {
    let partOneCups = [5, 6, 2, 8, 9, 3, 1, 4, 7]
    let partOneGame = CrabCups(cups: partOneCups)
    for _ in 0..<100 { partOneGame.executeMove() }
    print("Part one:", partOneGame.getOrder())

    let partTwoGame = CrabCups(cups: partOneCups + Array(10...1000000))
    for _ in 0..<10000000 { partTwoGame.executeMove() }
    print("Part two:", partTwoGame.valuesToNodes[1]!.next!.value * partTwoGame.valuesToNodes[1]!.next!.next!.value)
}

func getOrder(after node: Node) -> String {
    var seen: Set<Int> = []
    var result = ""
    var currentNode = node.next!
    while !seen.contains(currentNode.value) && currentNode.value != node.value {
        result += "\(currentNode.value)"
        seen.insert(currentNode.value)
        currentNode = currentNode.next!
    }

    return result
}

func printChain(from node: Node) {
    var seen: Set<Int> = []
    print(node)
    seen.insert(node.value)
    var currentNode = node.next
    while currentNode != nil && !seen.contains(currentNode!.value) {
        print(currentNode!)
        seen.insert(currentNode!.value)
        currentNode = currentNode!.next
    }
}

class Node: CustomStringConvertible {
    let value: Int
    var next: Node? = nil

    var description: String { "Value: \(value)" }

    init(value: Int) {
        self.value = value
    }
}


try main()
