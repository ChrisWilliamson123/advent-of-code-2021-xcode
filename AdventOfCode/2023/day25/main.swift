import Foundation
import Algorithms

class Node: Equatable, CustomStringConvertible{
    let id: String
    var connections: [Node] = []

    var description: String {
        "\(id): \(connections.map({ $0.id }))"
    }

    init(id: String) {
        self.id = id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.connections == rhs.connections
    }
}

struct Pair: Hashable {
    let first: String
    let second: String
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n")

    var nodes: [String: Node] = [:]
    for line in input {
//        print(line)
        let split = line.split(separator: ": ")
        let source = String(split[0])
        let targets = split[1].split(separator: " ").map(String.init)
//        print(source, targets)

        let sourceNode = nodes[source, default: Node(id: source)]
        let destinationNodes = targets.map({ nodes[$0, default: Node(id: $0)] })

        sourceNode.connections += destinationNodes
        for n in destinationNodes {
            n.connections += [sourceNode]
        }

        nodes[source] = sourceNode
        destinationNodes.forEach({
            nodes[$0.id] = $0
        })
    }

    for (_, node) in nodes {
        print(node)
    }

}

// Return true if all nodes visited
func bfs(graph: [String: Node], start: Node) -> Bool {
        return true
}

Timer.time(main)
