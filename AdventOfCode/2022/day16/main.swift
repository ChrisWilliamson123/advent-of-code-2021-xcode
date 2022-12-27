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
    let input: [String] = try readInput(fromTestFile: false)

    let valves = Set(input.map { line in
        let regex = Regex("Valve (\\w+) has flow rate=(\\d+); tunnels? leads? to valves? (.*)$")
        let matches = regex.getMatches(in: line)
        return Valve(name: matches[0], flowRate: Int(matches[1])!, destinations: Set(matches[2].components(separatedBy: ", ")))
     })

    let (distances, paths) = getDistancesAndPathsBetweenValves(valves: valves)

    struct CacheItem: Hashable {
        let start: Valve
        let valves: Set<Valve>
        let timeElapsed: Int
        let flowRate: Int
        let pressureReleased: Int
    }
    struct NodeCacheItem: Hashable {
        let timeElapsed: Int
        let currentNode: Valve
        let openValves: Set<Valve>
        let flowRate: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(timeElapsed)
            hasher.combine(currentNode)
            hasher.combine(openValves)
        }
    }
    var cache: [CacheItem: Int] = [:]
    var nodeCache: [NodeCacheItem: Int] = [:]

    // Enter into each dfs call with the pressure released for timeElapsed
    func dfs(start: Valve, valves: Set<Valve>, timeElapsed: Int, flowRate: Int, pressureReleased: Int, endTime: Int = 30) -> (Int, Set<Valve>) {
        nodeCache[NodeCacheItem(timeElapsed: timeElapsed, currentNode: start, openValves: Set(valves.filter { $0.isOpen }), flowRate: flowRate)] = pressureReleased
        let timeRemaining = endTime - timeElapsed
        if areAllPositiveValvesOpen(valves: valves) {
            let totalPressureReleased = pressureReleased + (timeRemaining * flowRate)
            return (totalPressureReleased, valves)
        }

        if timeElapsed >= endTime {
            return (pressureReleased, valves)
        }

        let nonOpenedPositiveValves = valves.filter { !$0.isOpen && $0.flowRate > 0 }
        let timeAllowedToGetToAndOpenValve = timeRemaining - 1
        let valvesWithinDistance = nonOpenedPositiveValves.filter { distances[[start.name, $0.name]]! <= timeAllowedToGetToAndOpenValve }
        if valvesWithinDistance.isEmpty {
            // Can't get to any more valves so finish
            let totalPressureReleased = pressureReleased + (timeRemaining * flowRate)
            return (totalPressureReleased, valves)
        }

        var best = 0
        var bestValves = valves
        for destination in valvesWithinDistance {
            let distanceToValve = distances[[start.name, destination.name]]!
            // Go to it and open it
            let valvesCopy = Set(valves.map { $0.copy() as! Valve })
            let valve = valvesCopy.first(where: { $0.name == destination.name })!
            valve.isOpen = true
            let result = dfs(start: valve, valves: Set(valvesCopy.map { $0.copy() as! Valve }), timeElapsed: timeElapsed + 1 + distanceToValve, flowRate: flowRate + valve.flowRate, pressureReleased: pressureReleased + (flowRate * distanceToValve) + (flowRate + valve.flowRate), endTime: endTime)
            if result.0 > best {
                bestValves = result.1
            }
            best = max(result.0, best)

        }
//        nodeCache[NodeCacheItem(timeRemaining: timeRemaining, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = best
        cache[CacheItem(start: start, valves: valves, timeElapsed: timeElapsed, flowRate: flowRate, pressureReleased: pressureReleased)] = best
        return (best, bestValves)
    }

//    func dfs(start: Valve, valves: Set<Valve>, timeElapsed: Int, flowRate: Int, pressureReleased: Int, target: Int = 30) -> (Int, Set<Valve>) {
//        if let cached = cache[CacheItem(start: start, valves: valves, timeElapsed: timeElapsed, flowRate: flowRate, pressureReleased: pressureReleased)] {
//            return (cached, valves)
//        }
//        if areAllPositiveValvesOpen(valves: valves) {
////            for i in stride(from: timeRemaining, to: 0, by: -1) {
////                nodeCache[NodeCacheItem(timeRemaining: i, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased + ((timeRemaining-i) * flowRate)
////            }
//            return (pressureReleased + ((target - timeElapsed) * flowRate), valves)
//        }
//        if timeElapsed >= target {
//            nodeCache[NodeCacheItem(timeElapsed: timeElapsed, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased
//            return (pressureReleased, valves)
//        }
//        let nonOpenedPositiveValves = valves.filter { !$0.isOpen && $0.flowRate > 0 }
//        let valvesWithinDistance = nonOpenedPositiveValves.filter { distances[[start.name, $0.name]]! < target - (timeElapsed - 1) }
////        print(valvesWithinDistance)
//        if valvesWithinDistance.isEmpty {
////            for i in stride(from: timeRemaining, to: 0, by: -1) {
////                nodeCache[NodeCacheItem(timeRemaining: i, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = pressureReleased + ((timeRemaining-i) * flowRate)
////            }
//            return (pressureReleased + ((target - timeElapsed) * flowRate), valves)
//        }
//        var best = 0
//        var bestValves = valves
//        for destination in valvesWithinDistance {
//            let distanceToValve = distances[[start.name, destination.name]]!
//            // Go to it and open it
//            let valvesCopy = Set(valves.map { $0.copy() as! Valve })
//            let valve = valvesCopy.first(where: { $0.name == destination.name })!
//            valve.isOpen = true
//            let result = dfs(start: valve, valves: Set(valvesCopy.map { $0.copy() as! Valve }), timeElapsed: timeElapsed + 1 + distanceToValve, flowRate: flowRate + valve.flowRate, pressureReleased: pressureReleased + (flowRate * distanceToValve) + (flowRate + valve.flowRate), target: target)
//            if result.0 > best {
//                bestValves = result.1
//            }
//            best = max(result.0, best)
//
//        }
////        nodeCache[NodeCacheItem(timeRemaining: timeRemaining, currentNode: start, openValves: Set(valves.filter({ $0.isOpen })), flowRate: flowRate)] = best
//        cache[CacheItem(start: start, valves: valves, timeElapsed: timeElapsed, flowRate: flowRate, pressureReleased: pressureReleased)] = best
//        return (best, bestValves)
//
//    }

    nodeCache.removeAll()
    let partOne = dfs(start: valves.first(where: { $0.name == "AA" })!,
                      valves: Set(valves.map({ $0.copy() as! Valve })),
                      timeElapsed: 0,
                      flowRate: 0,
                      pressureReleased: 0,
                      endTime: 29)
    print(partOne.0)
    print(nodeCache.count)
    let numberOfPositiveValves = valves.filter({ $0.flowRate > 0 }).count
    print(numberOfPositiveValves)
    let MINUTES = 10
    for k in 0..<25 {
        let minuteElevenEntries = Array(nodeCache.filter { $0.key.timeElapsed == k })
        for i in 0..<minuteElevenEntries.count {
            for j in i+1..<minuteElevenEntries.count {
                let openValvesI = minuteElevenEntries[i].key.openValves
                let openValvesJ = minuteElevenEntries[j].key.openValves
                if openValvesI.isDisjoint(with: openValvesJ) && openValvesI.count + openValvesJ.count == numberOfPositiveValves {
                    print(openValvesI, openValvesJ)
                    let combinedPressure = minuteElevenEntries[i].value + minuteElevenEntries[j].value
                    let combinedFlowRate = minuteElevenEntries[i].key.flowRate + minuteElevenEntries[j].key.flowRate
                    print(combinedFlowRate)
                    let timeRemaining = 25 - k
                    let totalPressureReleased = combinedPressure + (combinedFlowRate * timeRemaining)
                    print(totalPressureReleased)
                }
            }
        }
    }

//    // try to find earliest time where all valves can be open
//    for i in stride(from: 25, through: 0, by: -1) {
//        let cachedItems = Array(nodeCache.filter({ $0.key.timeRemaining == i }))
//        let openValves = cachedItems.map({ $0.key.openValves })
//        for j in 0..<openValves.count {
//            for k in j+1..<openValves.count {
//                if openValves[j].isDisjoint(with: openValves[k]) && openValves[j].union(openValves[k]).count == numberOfPositiveValves {
//                    print(i, openValves[j], openValves[k])
//                    print(cachedItems[j].value, cachedItems[j].value)
//                    let jEnd = cachedItems[j].value + (cachedItems[j].key.flowRate * i)
//                    let kEnd = cachedItems[k].value + (cachedItems[k].key.flowRate * i)
//                    print(jEnd + kEnd)
//                    break
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
