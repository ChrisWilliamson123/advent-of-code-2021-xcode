import Foundation

struct Part {
    let properties: [Character: Int]

    static func build(_ line: String) -> Part {
        let withoutBrackets = String(line)[1..<line.count-1]
        let properties = withoutBrackets.split(separator: ",").reduce(into: [:] as [Character: Int], { (current, propertyLine) in
            let pLineString = String(propertyLine)
            current[pLineString[0]] = Int(pLineString[2..<pLineString.count])!
        })
        return Part(properties: properties)
    }
}

enum Rule: Hashable {
    case comparison(Character, Comparator, Int, String)
    case destination(String)

    enum Comparator: String {
        case lessThan = "<"
        case moreThan = ">"
    }

    func process(_ part: Part) -> String? {
        switch self {
        case .comparison(let property, let comparator, let value, let destination):
            let propValue = part.properties[property]!
            if comparator == .lessThan && propValue < value {
                return destination
            } else if comparator == .moreThan && propValue > value {
                return destination
            }
        case .destination(let destination):
            return destination
        }

        return nil
    }
}

struct Workflow {
    let id: String
    let rules: [Rule]

    static func build(_ line: String) -> Workflow {
        let split = line.split(separator: "{")
        let id = String(split[0])
        let rules = split[1].split(separator: ",").map({ ruleString in
            let regex = Regex("(\\w+)(<|>)(\\d+):(\\w+)")
            let matches = regex.getMatches(in: String(ruleString))
            if matches.isEmpty {
                return Rule.destination(String(ruleString)[0..<ruleString.count-1])
            } else {
                return Rule.comparison(matches[0].first!, Rule.Comparator(rawValue: matches[1])!, Int(matches[2])!, matches[3])
            }
        })
        return Workflow(id: id, rules: rules)
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")

    let workflows = input[0].split(separator: "\n").map({ Workflow.build(String($0)) })
    let parts = input[1].split(separator: "\n").map({ Part.build(String($0)) })

    var part1 = 0
    for part in parts {
        var currentDestination = "in"
        while currentDestination != "A" && currentDestination != "R" {
            let currentWorkflow = workflows.first(where: { $0.id == currentDestination })!

            for rule in currentWorkflow.rules {
                if let newDestination = rule.process(part) {
                    currentDestination = newDestination
                    break
                }
            }
        }
        if currentDestination == "A" {
            part1 += Array(part.properties.values).sum()
        }
    }

    print(part1)

    // Part 2
    let workflowsDict = workflows.reduce(into: [:], { (current, next) in current[next.id] = next.rules })
    print(dfs(graph: workflowsDict, node: Node(id: "in", ranges: ["x": 1...4000, "m": 1...4000, "a": 1...4000, "s": 1...4000])))

}

struct Node {
    let id: String
    let ranges: [Character: ClosedRange<Int>]
}
private func dfs(graph: [String: [Rule]], node: Node) -> Int {
    var stack = Stack<Node>()
    stack.push(node)

    var total = 0
    while let current = stack.pop() {
        if current.id == "A" {
            total += Array(current.ranges.values).map({ $0.count }).multiply()
            continue
        }
        guard let neighbours = graph[current.id] else { continue }
        var continuingRanges = current.ranges
        for neighbour in neighbours {
            switch neighbour {
            case .destination(let destination):
                stack.push(Node(id: destination, ranges: continuingRanges))
            case .comparison(let property, let comparator, let value, let dest):
                var nextRanges = continuingRanges
                if comparator == .lessThan {
                    if nextRanges[property]!.upperBound >= value {
                        nextRanges[property] = nextRanges[property]!.lowerBound...value-1
                        continuingRanges[property] = value...continuingRanges[property]!.upperBound
                    }
                } else {
                    if nextRanges[property]!.lowerBound <= value {
                        nextRanges[property] = value+1...nextRanges[property]!.upperBound
                        continuingRanges[property] = continuingRanges[property]!.lowerBound...value
                    }
                }
                stack.push(Node(id: dest, ranges: nextRanges))
            }
        }
    }
    return total
}

Timer.time(main)
