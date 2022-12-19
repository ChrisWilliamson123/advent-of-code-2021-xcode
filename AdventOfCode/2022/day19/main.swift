import Foundation

enum Material: String, CaseIterable {
    case ore
    case clay
    case obsidian
    case geode
}

struct Robot: Hashable {
    let buildMaterial: Material?
    let buildMaterialRequirement: Int?
    let oreRequirement: Int
    let miningMaterial: Material
}

struct Blueprint {
    let id: Int
    let robots: [Material: Robot]
}

class RobotFactory {
    struct State: Hashable {
        var materialsAtEnd: [Material: Int]
        var robotsAtEnd: [Material: Int]
        let robotToBuild: Robot?
    }

    let blueprint: Blueprint
    var materialStore: [Material: Int] = Material.allCases.reduce(into: [:], { $0[$1] = 0 })
    var robots: [Material: Int]
    var currentBuild: Robot? = nil
    var currentState: State

    init(blueprint: Blueprint) {
        self.blueprint = blueprint

        self.robots = [
            .ore: 1,
            .clay: 0,
            .obsidian: 0,
            .geode: 0
        ]

        currentState = State(materialsAtEnd: materialStore, robotsAtEnd: robots, robotToBuild: nil)
    }

    private func getNextStates(from currentState: State, minsRemaining: Int) -> Set<State> {
        // Can only build one robot per minute
        var newRobots = currentState.robotsAtEnd
        if let newRobot = currentState.robotToBuild {
            newRobots[newRobot.miningMaterial]! += 1
        }
//        print("FR:", finishedRobot)
        var robotsToBuild: [Material] = [.obsidian, .geode]
        if minsRemaining < 10 {
            robotsToBuild.append(.ore)
        }

        if minsRemaining < 15 {
            robotsToBuild.append(.clay)
        }
        // Loop through all robots, and create a state where that is built (if we have resources
        var states = robotsToBuild.compactMap { material in
            // Check if we have mats to build robot
            var currentMaterials = currentState.materialsAtEnd
            let oreNeeded = blueprint.robots[material]!.oreRequirement
            let otherBuildMaterial = blueprint.robots[material]!.buildMaterial
            let otherBuildMaterialRequired = blueprint.robots[material]!.buildMaterialRequirement

            // First case is if we need two mats to build robot
            if let otherBuildMaterial = otherBuildMaterial {
                if otherBuildMaterialRequired! <= currentMaterials[otherBuildMaterial]! && oreNeeded <= currentMaterials[.ore]! {
                    currentMaterials[.ore]! -= oreNeeded
                    currentMaterials[otherBuildMaterial]! -= blueprint.robots[material]!.buildMaterialRequirement!
                    return State(materialsAtEnd: currentMaterials, robotsAtEnd: newRobots, robotToBuild: blueprint.robots[material]!)
                } else {
                    return nil
                }
            }
            // Second case is if we just need ore
            else if oreNeeded <= currentMaterials[.ore]! {
                currentMaterials[.ore]! -= oreNeeded
                return State(materialsAtEnd: currentMaterials, robotsAtEnd: newRobots, robotToBuild: blueprint.robots[material]!)
            }
            // Third case is if we don't match requirements to build robot
            else {
                return nil
            }
        }

        // Second, get the new materials from existing robots
        for i in 0..<states.count {
            var materialsAtEnd = states[i].materialsAtEnd
            Material.allCases.forEach { materialsAtEnd[$0]! += newRobots[$0]! }
            states[i] = State(materialsAtEnd: materialsAtEnd, robotsAtEnd: newRobots, robotToBuild: states[i].robotToBuild)
        }

//        // Remove other states if we can build a geode robot
        if let index = states.firstIndex(where: { $0.robotToBuild?.miningMaterial == .geode }) {
            return [states[index]]
        }

        // Add the state where we just mine materials
        var materialsAtEnd = currentState.materialsAtEnd
        Material.allCases.forEach { materialsAtEnd[$0]! += newRobots[$0]! }
        states.append(State(materialsAtEnd: materialsAtEnd, robotsAtEnd: newRobots, robotToBuild: nil))
        return Set(states)
    }

    func beginProduction() {
        func dfs(currentState: State, minutesElapsed: Int, geodesRetrieved: Int) -> Int {
            if minutesElapsed == 24 { return currentState.materialsAtEnd[.geode]! }
            let nextStates = getNextStates(from: currentState, minsRemaining: minutesElapsed)
            var gr = 0
//            var results: [Int] = []
//            let queue = OperationQueue()
//            print(nextStates.count)
//            queue.maxConcurrentOperationCount = nextStates.count
            for state in nextStates {
//                queue.addOperation(
//                    BlockOperation(block: {
                let result = dfs(currentState: state, minutesElapsed: minutesElapsed + 1, geodesRetrieved: state.materialsAtEnd[.geode]!)
                gr = max(gr, result)
//                    })
//                )
            }
//            queue.waitUntilAllOperationsAreFinished()
//            gr = results.max() ?? 0
            return gr
        }
        print(dfs(currentState: currentState, minutesElapsed: 0, geodesRetrieved: 0))
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: true)
    let blueprints = input.enumerated().map { (index, line) in createBlueprint(from: line, index: index) }
    let factory = RobotFactory(blueprint: blueprints[0])
    factory.beginProduction()
}

private func createBlueprint(from line: String, index: Int) -> Blueprint {
    let oreRegex = Regex("Each ore robot costs (\\d+) ore")
    let clayRegex = Regex("Each clay robot costs (\\d+) ore")
    let obsidianRegex = Regex("Each obsidian robot costs (\\d+) ore and (\\d+) (clay)")
    let geodeRegex = Regex("Each geode robot costs (\\d+) ore and (\\d+) (obsidian)")

    let oreRobot = getRobotFromRegex(oreRegex, line: line, miningMaterial: .ore)
    let clayRobot = getRobotFromRegex(clayRegex, line: line, miningMaterial: .clay)
    let obsidianRobot = getRobotFromRegex(obsidianRegex, line: line, miningMaterial: .obsidian)
    let geodeRobot = getRobotFromRegex(geodeRegex, line: line, miningMaterial: .geode)

    return Blueprint(id: index + 1, robots: [
        .ore: oreRobot,
        .clay: clayRobot,
        .obsidian: obsidianRobot,
        .geode: geodeRobot
    ])
}

private func getRobotFromRegex(_ regex: Regex, line: String, miningMaterial: Material) -> Robot {
    let matches = regex.getMatches(in: line)
    if matches.count > 3 {
        return Robot(buildMaterial: Material.init(rawValue: matches[3]), buildMaterialRequirement: Int(matches[2])!, oreRequirement: Int(matches[1])!, miningMaterial: miningMaterial)
    } else {
        return Robot(buildMaterial: nil, buildMaterialRequirement: nil, oreRequirement: Int(matches[1])!, miningMaterial: miningMaterial)
    }
}

Timer.time(main)
