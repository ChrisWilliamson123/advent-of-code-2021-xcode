import Foundation

/*
 Flip flop - % - either on or off. Default off. If receive high, noop. if receive low, toggle and send high if new = on else send low.

 Conjunction - & - remember most recent from each input, default low. When receive new, update memory. If all are high, send low, otherwise send high.

 Single broadcast module - relay input pulse to all destinations.

 Button module - when pushed, low pulse is sent to broadcast module, wait for all modules to complete before pressing again.

 Receives are always handled in order of receival
 */
enum Signal {
    case high
    case low
}

open class Module: CustomStringConvertible {
    let id: String
    let destinations: [String]
    weak var coordinator: CommunicationCoordinator?

    public var description: String {
        "\(String(describing: Self.self)) -> \(destinations)"
    }

    init(id: String, destinations: [String]) {
        self.id = id
        self.destinations = destinations
    }

    func processOperation(_ operation: Operation) { }
}

final class FlipFlopModule: Module {
    var isOn: Bool = false

    override var description: String {
        "\(super.description) \(isOn)"
    }

    override func processOperation(_ operation: Operation) {
        guard operation.value == .low else { return }

        isOn.toggle()

        destinations.forEach({
            coordinator?.operations.append(.init(destination: $0, value: isOn ? .high : .low, sender: id))
        })
    }
}

final class ConjunctionModule: Module {
    var recentSignals: [String: Signal] = [:]

    var didChangeOrdering: [String: Int] = [:]

    var allSignalsHigh: Bool {
        !recentSignals.values.contains(.low)
    }

    override var description: String {
        "\(super.description) \(recentSignals)"
    }

    override func processOperation(_ operation: Operation) {
        let old = recentSignals[operation.sender]!
        recentSignals[operation.sender]! = operation.value
        if operation.value != old && didChangeOrdering[operation.sender] == nil {
            didChangeOrdering[operation.sender] = didChangeOrdering.count
        }

        let signalsHigh = allSignalsHigh
        destinations.forEach({
            coordinator?.operations.append(.init(destination: $0, value: signalsHigh ? .low : .high, sender: id))
        })
    }

    func getSignalsString() -> String {
        var str = ""
        for (key, _) in didChangeOrdering.sorted(by: { $0.value < $1.value }) {
            str += "\(recentSignals[key]! == .high ? "1" : "0")"
        }
        return str + " - \(didChangeOrdering.count)/\(recentSignals.count)"
    }
}

final class BroadcastModule: Module {
    override func processOperation(_ operation: Operation) {
        destinations.forEach({
            coordinator?.operations.append(.init(destination: $0, value: .low, sender: id))
        })
    }
}

final class ButtonModule: Module {
    func pushButton() {
        coordinator?.operations.append(.init(destination: "broadcaster", value: .low, sender: id))
    }
}

struct Operation: CustomStringConvertible {
    let destination: String
    let value: Signal
    let sender: String

    var description: String {
        "\(sender) -\(value == .low ? "low" : "high")-> \(destination)"
    }
}

final class CommunicationCoordinator {
    let modules: [String: Module]
    var operations = [Operation]()

    var pulsesSent: [Signal: Int] = [
        .low: 0,
        .high: 0
    ]

    var buttonModule: ButtonModule {
        modules["button"]! as! ButtonModule
    }

    var conjunctionModules: [ConjunctionModule] {
        modules.compactMap { ($0.value as? ConjunctionModule) }
    }

    init(modules: [String: Module]) {
        self.modules = modules
        self.modules.values.forEach({
            $0.coordinator = self
        })
    }

    // Ensures conjunction modules have their initial input modules and signals assigned
    func setupConjunctionModules() {
        for (id, module) in modules {
            let cms = module.destinations.compactMap({ modules[$0] as? ConjunctionModule })
            cms.forEach({
                $0.recentSignals[id] = .low
            })
        }
//        for c in conjunctionModules {
//            print(c.id, c.recentSignals)
//        }
    }

    func pushButton() {
        buttonModule.pushButton()
//        pulsesSent[.low]! += 1
    }

    func processOperations() -> Bool? {
        while !operations.isEmpty {
            let operation = operations.removeFirst()
//            print(operation)
            // Set inputs in conjunction modules
//            conjunctionModules.forEach({
//                if $0.recentSignals[operation.destination] != nil {
//
//                    $0.recentSignals[operation.destination]! = operation.value
//                }
//            })

            guard let receivingModule = modules[operation.destination] else {
//                print("no receiving module: \(operation.destination)")
//                assert(false, "Could not get module for operation")

                if operation.destination == "rx" && operation.value == .low {
                    print("Done")
                    return true
                }
                pulsesSent[operation.value]! += 1
                continue
            }

            receivingModule.processOperation(operation)
            pulsesSent[operation.value]! += 1

        }
        return nil
    }
}

private func buildModules(from lines: [String]) -> [String: Module] {
    var modules: [String: Module] = [:]

    for line in lines {
        let split = line.split(separator: " -> ")
        let destinations = split[1].split(separator: ", ").map({ String($0) })
        switch line[0] as Character {
        case "b":
            modules["broadcaster"] = BroadcastModule(id: "broadcaster", destinations: destinations)
        case "%":
            let id = String(split[0])[1..<split[0].count]
            modules[id] = FlipFlopModule(id: id, destinations: destinations)
        case "&":
            let id = String(split[0])[1..<split[0].count]
            modules[id] = ConjunctionModule(id: id, destinations: destinations)
        default: assert(false, "Invalid line found")
        }
    }

    modules["button"] = ButtonModule(id: "button", destinations: ["broadcaster"])

    return modules
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")

    // Need to hold all modules (dict of id to module?)
    // Need to hold an array of operations to process (stack?)
    let modules = buildModules(from: input)
//    for (k, v) in modules {
//        print(k, v)
//    }

    let coordinator = CommunicationCoordinator(modules: modules)
    coordinator.setupConjunctionModules()
    var i = 0
    while true {
        coordinator.pushButton()
        i += 1
        let exitOnLowRx = coordinator.processOperations()
        if exitOnLowRx == true {
            print(i)
            exit(0)
        }
//        for m in coordinator.conjunctionModules {
//            print(m.id, m.getSignalsString())
//        }
//        print("====================")
//        for m in coordinator.modules {
//            print(m)
//        }
//        print("========")
    }
    print(coordinator.pulsesSent)
    print(coordinator.pulsesSent[.high]! * coordinator.pulsesSent[.low]!)
}

Timer.time(main)

// 737800400 - too high
