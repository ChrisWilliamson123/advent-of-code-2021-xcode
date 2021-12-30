import Foundation

typealias Graph = [String: Set<String>]

func main() throws {
    let isTestMode = CommandLine.arguments.contains("test")
    let input: [String] = try readInput(fromTestFile: isTestMode)

    var graph: Graph = [:]

    for l in input {
        let split = l.split(separator: "-").map({ String($0) })
        if graph[split[0]] != nil {
            graph[split[0]]!.insert(split[1])
        } else {
            graph[split[0]] = [split[1]]
        }

        if graph[split[1]] != nil {
            graph[split[1]]!.insert(split[0])
        } else {
            graph[split[1]] = [split[0]]
        }
    }

    var paths = getPaths(graph: graph, node: "start", visitedSmalls: [:], doubleSmallCave: nil)
    print("Part 1:", paths.count)

    let smallCaves = graph.keys.filter({ $0.isSmallCave && $0 != "start" && $0 != "end" })
    paths = []
    for s in smallCaves {
        paths.append(contentsOf: getPaths(graph: graph, node: "start", visitedSmalls: [:], doubleSmallCave: s))
    }

    let all = Array(Set(paths)).sorted(by: { $0.joined() < $1.joined() })
    print("Part 2:", all.count)
}

private func getPaths(graph: Graph, node: String, visitedSmalls: [String: Int], doubleSmallCave: String?) -> [[String]] {
    if node == "end" { return [[node]] }

    var visitedSmalls = visitedSmalls
    
    var paths: [[String]] = []
    if node.isSmallCave {
        visitedSmalls[node] = visitedSmalls[node, default: 0] + 1
    }

    for child in graph[node]! {
        if let visitedSmallCount = visitedSmalls[child] {
            if let doubleSmallCave = doubleSmallCave, child == doubleSmallCave {
                if visitedSmallCount == 2 {
                    continue
                }
            } else {
                continue
            }

        }

        let childPaths = getPaths(graph: graph, node: child, visitedSmalls: visitedSmalls, doubleSmallCave: doubleSmallCave)
        for p in childPaths {
            paths.append([node] + p)
        }
    }

    return paths
}

extension String {
    var isSmallCave: Bool {
        !isUppercase
    }

    var isUppercase: Bool {
        for c in self {
            if c.isLowercase {
                return false
            }
        }
        return true
    }
}

try main()
