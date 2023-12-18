import Foundation

enum Direction: String {
    case left = "L"
    case right = "R"
}

final class Node {
    let value: String

    var left: Node?
    var right: Node?

    init(value: String, left: Node? = nil, right: Node? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

//    static func build(from line: String) -> Node {
//        let regex = Regex("\\w+")
//        let words = regex.getGreedyMatches(in: line)
//        return Node(value: <#T##String#>, left: <#T##Node#>, right: <#T##Node#>)
//    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    var directions = input[0].map { Direction(rawValue: String($0)) }

    var nodes: [String: Node] = [:]
    for line in input[1..<input.count] {
        let regex = Regex("\\w+")
        let words = regex.getGreedyMatches(in: line)
        nodes[words[0]] = Node(value: words[0])
    }

    for line in input[1..<input.count] {
//        print(line)
        let regex = Regex("\\w+")
        let words = regex.getGreedyMatches(in: line)
        nodes[words[0]]?.left = nodes[words[1]]
        nodes[words[0]]?.right = nodes[words[2]]
    }
    print(nodes)

//    var currentNode = nodes["AAA"]!
//    var steps = 0
//    while currentNode.value != "ZZZ" {
//        if directions[0] == .right {
//            currentNode = currentNode.right!
//        } else {
//            currentNode = currentNode.left!
//        }
//        directions.rotateLeft(positions: 1)
//        steps += 1
//    }
//    print(steps)
    var stepsToComplete: [Int] = []
    var currentNodes = Array(nodes.filter({ $0.key.last! == "A" }).values)
//    var steps = 0
    for cn in currentNodes {
        var currentNode = cn
        var steps = 0
        var currentDirections = directions
        while currentNode.value.last! != "Z" {
            print(currentNode.value)
            if currentDirections[0] == .right {
                currentNode = currentNode.right!
            } else {
                currentNode = currentNode.left!
            }
            currentDirections.rotateLeft(positions: 1)
            steps += 1
        }
        stepsToComplete.append(steps)
    }

    var lcm = stepsToComplete[0]
    for i in 1..<stepsToComplete.count {
        lcm = findLCM(n1: lcm, n2: stepsToComplete[i])
    }
    print(lcm)
//    while currentNodes.contains(where: { $0.value.last! != "Z" }) {
//        for index in 0..<currentNodes.count {
//            let currentNode = currentNodes[index]
//            if directions[0] == .right {
//                currentNodes[index] = currentNode.right!
//            } else {
//                currentNodes[index] = currentNode.left!
//            }
//        }
//        directions.rotateLeft(positions: 1)
//        steps += 1
//    }
//    print(currentNodes)
//    print(steps)
}

// Function to find gcd of two numbers
func findGCD(_ num1: Int, _ num2: Int) -> Int {
   var x = 0

   // Finding maximum number
   var y: Int = max(num1, num2)

   // Finding minimum number
   var z: Int = min(num1, num2)

   while z != 0 {
      x = y
      y = z
      z = x % y
   }
   return y
}

// Function to find lcm of two numbers
func findLCM(n1: Int, n2: Int) -> Int {
   return (n1 * n2/findGCD(n1, n2))
}

Timer.time(main)
