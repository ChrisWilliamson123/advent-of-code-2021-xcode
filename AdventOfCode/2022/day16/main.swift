import Foundation

class Valve: Hashable, CustomStringConvertible, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Valve(name: self.name, flowRate: self.flowRate, destinations: self.destinations, isOpen: self.isOpen)
    }

    static func == (lhs: Valve, rhs: Valve) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(flowRate)
        hasher.combine(destinations)
        hasher.combine(isOpen)
    }

    let name: String
    let flowRate: Int
    let destinations: Set<String>
    var isOpen: Bool = false

    var description: String {
        name
    }

    init(name: String, flowRate: Int, destinations: Set<String>, isOpen: Bool = false) {
        self.name = name
        self.flowRate = flowRate
        self.destinations = destinations
        self.isOpen = isOpen
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true)

    let valves = Set(input.map { line in
        let regex = Regex("Valve (\\w+) has flow rate=(\\d+); tunnels? leads? to valves? (.*)$")
        let matches = regex.getMatches(in: line)
        return Valve(name: matches[0], flowRate: Int(matches[1])!, destinations: Set(matches[2].components(separatedBy: ", ")))
     })

    let (distances, paths) = getDistancesAndPathsBetweenValves(valves: valves)



//    for (key, value) in distances {
//        print(key, value)
//    }
    struct CacheItem: Hashable {
        let start: Valve
        let valves: Set<Valve>
        let timeRemaining: Int
        let flowRate: Int
        let pressureReleased: Int
    }
    struct NodeCacheItem: Hashable {
        let timeRemaining: Int
        let currentNode: Valve
        let openValves: Set<Valve>
        let flowRate: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(timeRemaining)
            hasher.combine(currentNode)
            hasher.combine(openValves)
        }
    }
    var cache: [CacheItem: Int] = [:]
    var nodeCache: [NodeCacheItem: Int] = [:]
//    var nodesCache:
    func dfs(start: Valve, valves: Set<Valve>, timeRemaining: Int, flowRate: Int, pressureReleased: Int) -> (Int, Set<Valve>) {
        if let cached = cache[CacheItem(start: start, valves: valves, timeRemaining: timeRemaining, flowRate: flowRate, pressureReleased: pressureReleased)] {
            return (cached, valves)
        }
        if areAllPositiveValvesOpen(valves: valves) {
            for i in stride(from: timeRemaining, to: 0, by: -1) {
                nodeCache[NodeCacheItem(timeRemaining: i, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased + ((timeRemaining-i) * flowRate)
            }
            return (pressureReleased + ((timeRemaining) * flowRate), valves)
        }
        if timeRemaining <= 0 {
            nodeCache[NodeCacheItem(timeRemaining: timeRemaining, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased
            return (pressureReleased, valves)
        }
        let nonOpenedPositiveValves = valves.filter { !$0.isOpen && $0.flowRate > 0 }
        let valvesWithinDistance = nonOpenedPositiveValves.filter { distances[[start.name, $0.name]]! < timeRemaining - 1 }
//        print(valvesWithinDistance)
        if valvesWithinDistance.isEmpty {
            for i in stride(from: timeRemaining, to: 0, by: -1) {
                nodeCache[NodeCacheItem(timeRemaining: i, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased + ((timeRemaining-i) * flowRate)
            }
            return (pressureReleased + (timeRemaining * flowRate), valves)
        }
        var best = 0
        var bestValves = valves
        for destination in valvesWithinDistance {
            let distanceToValve = distances[[start.name, destination.name]]!
            // Go to it and open it
            let valvesCopy = Set(valves.map { $0.copy() as! Valve })
            let valve = valvesCopy.first(where: { $0.name == destination.name })!
            valve.isOpen = true
            let result = dfs(start: valve, valves: Set(valvesCopy.map { $0.copy() as! Valve }), timeRemaining: timeRemaining - 1 - distanceToValve, flowRate: flowRate + valve.flowRate, pressureReleased: pressureReleased + (flowRate * distanceToValve) + (flowRate + valve.flowRate))
            if result.0 > best {
                bestValves = result.1
            }
            best = max(result.0, best)

        }
        nodeCache[NodeCacheItem(timeRemaining: timeRemaining, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = best
        cache[CacheItem(start: start, valves: valves, timeRemaining: timeRemaining, flowRate: flowRate, pressureReleased: pressureReleased)] = best
        return (best, bestValves)

    }

//    let result = dfs(start: valves.first(where: { $0.name == "AA" })!, valves: Set(valves.map({ $0.copy() as! Valve })), timeRemaining: 29, flowRate: 0, pressureReleased: 0)
//    print(result.0)
    nodeCache.removeAll()
    let partOne = dfs(start: valves.first(where: { $0.name == "AA" })!, valves: Set(valves.map({ $0.copy() as! Valve })), timeRemaining: 29, flowRate: 0, pressureReleased: 0)
    print(partOne.0)

    // try to find earliest time where all valves can be open
    let numberOfPositiveValves = valves.filter({ $0.flowRate > 0 }).count
    for i in stride(from: 25, through: 0, by: -1) {
        let cachedItems = Array(nodeCache.filter({ $0.key.timeRemaining == i }))
        let openValves = cachedItems.map({ $0.key.openValves })
        for j in 0..<openValves.count {
            for k in j+1..<openValves.count {
                if openValves[j].isDisjoint(with: openValves[k]) && openValves[j].union(openValves[k]).count == numberOfPositiveValves {
                    print(i, openValves[j], openValves[k])
                    print(cachedItems[j].value, cachedItems[j].value)
                    let jEnd = cachedItems[j].value + (cachedItems[j].key.flowRate * i)
                    let kEnd = cachedItems[k].value + (cachedItems[k].key.flowRate * i)
                    print(jEnd + kEnd)
                    break
                }
            }
        }
    }
////    print(nodeCache.count)
////    print("Unopened: ", result.1.filter({ !$0.isOpen }))
//////    let ele = dfs(start: result.1.first(where: { $0.name == "AA" })!, valves: result.1, timeRemaining: 25, flowRate: result.1.filter({ $0.isOpen }).map({$0.flowRate}).sum(), pressureReleased: 0)
////    cache.removeAll()
////    let ele = dfs(start: result.1.first(where: { $0.name == "AA" })!, valves: result.1, timeRemaining: 25, flowRate: 0, pressureReleased: 0)
////    print(ele.0)
////    let
//    let sorted = Array(nodeCache.filter({ $0.key.timeRemaining == 5 }).sorted(by: { $0.value < $1.value }).reversed())
//    print(sorted.count)
//    print(sorted)
//    print(numberOfPositiveValves)
//    for i in 0..<sorted.count {
//        print("\n")
//        for j in i+1..<sorted.count {
//            let first = Set(sorted[i].key.openValves.map({ $0.name }))
////            print(first.count)
//            let second = Set(sorted[j].key.openValves.map({ $0.name }))
////            print(second.count)
//            if first.count + second.count == numberOfPositiveValves {
//                print("testing")
//                print(sorted[i].key.openValves)
//                print(sorted[j].key.openValves)
//                if first.isDisjoint(with: second) {
//                    print(sorted[i].value + sorted[j].value)
//                }
//            }
//        }
//    }
}

private func areAllPositiveValvesOpen(valves: Set<Valve>) -> Bool {
    let positiveValves = valves.filter({ $0.flowRate > 0 })
    if positiveValves.contains(where: { !$0.isOpen }) {
        return false
    }
    return true
}

private func getDistancesAndPathsBetweenValves(valves: Set<Valve>) -> (distances: [[String]: Int], paths: [[String]: [String]]) {
    var distances: [[String]: Int] = [:]
    var paths: [[String]: [String]] = [:]

    for valve in valves where valve.flowRate > 0 || valve.name == "AA" {
        distances[[valve.name, valve.name]] = 0
        paths[[valve.name, valve.name]] = []

        let others = valves.filter({ $0 != valve && $0.flowRate > 0 })
        for otherValve in others {
            let result = dijkstra(graph: valves,
                                  source: valve,
                                  target: otherValve,
                                  getNeighbours: { current in Set(current.destinations.compactMap({ destName in valves.first(where: { $0.name == destName }) })) },
                                  getDistanceBetween: { _, _ in 1})
            var path = [String]()
            var current = otherValve
            while true {
                path.insert(current.name, at: 0)
                if let prev = result.chain[current] {
                    current = prev!
                } else {
                    break
                }
            }
            distances[[valve.name, otherValve.name]] = result.distances[otherValve]!
            paths[[valve.name, otherValve.name]] = path
        }
    }

    return (distances, paths)
}

Timer.time(main)
