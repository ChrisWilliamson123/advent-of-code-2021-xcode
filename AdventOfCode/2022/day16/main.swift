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
    var cache: [CacheItem: Int] = [:]
    func dfs(start: Valve, valves: Set<Valve>, timeRemaining: Int, flowRate: Int, pressureReleased: Int) -> Int {
//        print(start.name, timeRemaining)
        if let cached = cache[CacheItem(start: start, valves: valves, timeRemaining: timeRemaining, flowRate: flowRate, pressureReleased: pressureReleased)] {
            return cached
        }
        if areAllPositiveValvesOpen(valves: valves) {
            return pressureReleased + ((timeRemaining) * flowRate)
        }
        if timeRemaining <= 0 {
            return pressureReleased
        }
        let neighbours = start.destinations
        var best = 0
        for n in neighbours {
            let valve = valves.first(where: { $0.name == n })!
            if valve.flowRate > 0 && timeRemaining > 1 && valve.isOpen == false {
                // Open it and recurse
                let valvesCopy = Set(valves.map { $0.copy() as! Valve })
                let valve = valvesCopy.first(where: { $0.name == n })!
                valve.isOpen = true
                let result = dfs(start: valve, valves: Set(valvesCopy.map { $0.copy() as! Valve }), timeRemaining: timeRemaining - 2, flowRate: flowRate + valve.flowRate, pressureReleased: pressureReleased + flowRate + (flowRate + valve.flowRate))
                best = max(result, best)
            }
            // Recurse
//            let valve = valves.first(where: { $0.name == n })!
            let result = dfs(start: valve, valves: Set(valves.map { $0.copy() as! Valve }), timeRemaining: timeRemaining - 1, flowRate: flowRate, pressureReleased: pressureReleased + flowRate)
            best = max(result, best)
        }
        cache[CacheItem(start: start, valves: valves, timeRemaining: timeRemaining, flowRate: flowRate, pressureReleased: pressureReleased)] = best
        return best

    }

    let result = dfs(start: valves.first(where: { $0.name == "AA" })!, valves: Set(valves.map({ $0.copy() as! Valve })), timeRemaining: 29, flowRate: 0, pressureReleased: 0)
    print(result)
}

private func areAllPositiveValvesOpen(valves: Set<Valve>) -> Bool {
    let positiveValves = valves.filter({ $0.flowRate > 0 })
    if positiveValves.contains(where: { !$0.isOpen }) {
        return false
    }
    return true
}

private func getDistancesAndPathsBetweenValves(valves: Set<Valve>) -> (distances: [[Valve]: Int], paths: [[Valve]: [Valve]]) {
    var distances: [[Valve]: Int] = [:]
    var paths: [[Valve]: [Valve]] = [:]

    for valve in valves where valve.flowRate > 0 || valve.name == "AA" {
        distances[[valve, valve]] = 0
        paths[[valve, valve]] = []

        let others = valves.filter({ $0 != valve && $0.flowRate > 0 })
        for otherValve in others {
            let result = dijkstra(graph: valves,
                                  source: valve,
                                  target: otherValve,
                                  getNeighbours: { current in Set(current.destinations.compactMap({ destName in valves.first(where: { $0.name == destName }) })) },
                                  getDistanceBetween: { _, _ in 1})
            var path = [Valve]()
            var current = otherValve
            while true {
                path.insert(current, at: 0)
                if let prev = result.chain[current] {
                    current = prev!
                } else {
                    break
                }
            }
            distances[[valve, otherValve]] = result.distances[otherValve]!
            paths[[valve, otherValve]] = path
        }
    }

    return (distances, paths)
}

Timer.time(main)
