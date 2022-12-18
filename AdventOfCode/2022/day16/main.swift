import Foundation

class Valve: Hashable {
    static func == (lhs: Valve, rhs: Valve) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(flowRate)
        hasher.combine(destinations)
    }

    let name: String
    let flowRate: Int
    let destinations: Set<String>
    var isOpen: Bool = false

    init(name: String, flowRate: Int, destinations: Set<String>) {
        self.name = name
        self.flowRate = flowRate
        self.destinations = destinations
    }
}

class Cave {
    let valves: Set<Valve>
    let distancesBetweenValves: [[Valve]: Int]
    let shortestPathsBetweenValves: [[Valve]: [Valve]]
    var pressureReleased: Int = 0
    var totalFlowRate: Int = 0
    var timeRemaining: Int = 30 {
        didSet {
            pressureReleased += totalFlowRate
            print(timeRemaining, pressureReleased)
        }
    }
    lazy var populatedValve: Valve = {
        getValveWithName("AA")!
    }()

    var openValves: Set<Valve> {
        valves.filter { $0.isOpen }
    }

    init(valves: Set<Valve>, distanceBetweenValves: [[Valve]: Int], shortestPathsBetweenValves: [[Valve]: [Valve]]) {
        self.valves = valves
        self.distancesBetweenValves = distanceBetweenValves
        self.shortestPathsBetweenValves = shortestPathsBetweenValves
    }

    func run() {
        // THE BELOW JUST USES FLOW RATE TO GET NEXT VALUE
//        while timeRemaining > 0 {
//            let nextValve = getNextValve()
//            // Get the path to the next valve
//            let path = shortestPathsBetweenValves[[populatedValve, nextValve]]!
//            // Traverse path, opening valves with positive flow rate
//            if path.count == 0 {
//                // Do not move, time drops by one
//                timeRemaining -= 1
//                continue
//            }
//            for nextValveInPath in path[1..<path.count] {
//                populatedValve = nextValveInPath
//                timeRemaining -= 1
//                if !populatedValve.isOpen && populatedValve.flowRate > 0 {
//                    populatedValve.isOpen = true
//                    print("Opened valve \(populatedValve.name) at \(31-timeRemaining)")
//                    timeRemaining -= 1
//                    totalFlowRate += populatedValve.flowRate
//                }
//            }
//        }

        while timeRemaining > 0 {
            let possibleDestinations = valves.filter { !$0.isOpen }
            let bestDestination = possibleDestinations.max(by: { getValueOfMovingToDestination($0) < getValueOfMovingToDestination($1) })
            print("Best: ", bestDestination?.name)
            if let bestDestination = bestDestination {
                let path = shortestPathsBetweenValves[[populatedValve, bestDestination]]!
                // Traverse path, opening valves with positive flow rate
                if path.count == 0 {
                    // Do not move, time drops by one
                    timeRemaining -= 1
                    continue
                }
                for nextValveInPath in path[1..<path.count] {
                    populatedValve = nextValveInPath
                    print("You move to valve \(populatedValve.name)")
                    timeRemaining -= 1
                    if !populatedValve.isOpen && populatedValve == bestDestination {

                        populatedValve.isOpen = true
                        print("You open valve \(populatedValve.name)")
                        timeRemaining -= 1
                        totalFlowRate += populatedValve.flowRate
                    }
//                    if !populatedValve.isOpen && populatedValve.flowRate > 0 {
//                    }
                }
            }
            else {
                // stick where we are
                timeRemaining -= 1
            }
//            let nextValve = getNextValve()
//            // Get the path to the next valve
//            let path = shortestPathsBetweenValves[[populatedValve, nextValve]]!
//            // Traverse path, opening valves with positive flow rate
//            if path.count == 0 {
//                // Do not move, time drops by one
//                timeRemaining -= 1
//                continue
//            }
//            for nextValveInPath in path[1..<path.count] {
//                populatedValve = nextValveInPath
//                timeRemaining -= 1
//                if !populatedValve.isOpen && populatedValve.flowRate > 0 {
//                    populatedValve.isOpen = true
//                    print("Opened valve \(populatedValve.name) at \(31-timeRemaining)")
//                    timeRemaining -= 1
//                    totalFlowRate += populatedValve.flowRate
//                }
//            }
        }
    }

    private func getValveWithName(_ name: String) -> Valve? {
        valves.first(where: { $0.name == name })
    }

    private func getNextValve() -> Valve {
        let closedValves = valves.filter { !$0.isOpen }
        let valveWithBestRate = closedValves.max(by: { $0.flowRate < $1.flowRate })
        return valveWithBestRate ?? populatedValve
    }

    private func getValueOfMovingToDestination(_ destination: Valve) -> Int {
        let shortestPathToDestination = shortestPathsBetweenValves[[populatedValve, destination]]!
        if shortestPathToDestination.count == 0 { return 0 }
        return destination.flowRate / (shortestPathToDestination.count - 1)
//        var value = 0
//        if shortestPathToDestination.count == 0 { return 0 }
//        for (i, valve) in shortestPathToDestination[1..<shortestPathToDestination.count].enumerated() {
//            value += valve.flowRate / (i+1)
//        }
//        print("\(populatedValve.name) -> \(destination.name) value: \(value)")
//        return value
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    let valves = Set(input.map { line in
        let regex = Regex("Valve (\\w+) has flow rate=(\\d+); tunnels? leads? to valves? (.*)$")
        let matches = regex.getMatches(in: line)
        return Valve(name: matches[0], flowRate: Int(matches[1])!, destinations: Set(matches[2].components(separatedBy: ", ")))
     })

    var distances: [[Valve]: Int] = [:]
    var paths: [[Valve]: [Valve]] = [:]

    for valve in valves {
        distances[[valve, valve]] = 0
        paths[[valve, valve]] = []

        let others = valves.filter({ $0 != valve })
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

    let cave = Cave(valves: valves, distanceBetweenValves: distances, shortestPathsBetweenValves: paths)
    cave.run()
}

Timer.time(main)
