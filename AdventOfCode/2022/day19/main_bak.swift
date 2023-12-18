// import Foundation
//
// enum Material: String, CaseIterable {
//    case ore
//    case clay
//    case obsidian
//    case geode
// }
//
// struct Robot: Hashable {
//    let buildMaterial: Material?
//    let buildMaterialRequirement: Int?
//    let oreRequirement: Int
//    let miningMaterial: Material
// }
//
// struct Blueprint {
//    let id: Int
//    let robots: [Material: Robot]
// }
//
// class RobotFactory {
//    struct State: Hashable {
//        var materialsAtEnd: [Material: Int]
//        var robotsAtEnd: [Material: Int]
//        let robotToBuild: Robot?
//    }
//
//    let blueprint: Blueprint
//    var materialStore: [Material: Int] = Material.allCases.reduce(into: [:], { $0[$1] = 0 })
//    var robots: [Material: Int]
//    var currentBuild: Robot? = nil
//    var currentState: State
//    private lazy var oreRobot: Robot = {
//        blueprint.robots[.ore]!
//    }()
//    private lazy var clayRobot: Robot = {
//        blueprint.robots[.clay]!
//    }()
//    private lazy var obsidianRobot: Robot = {
//        blueprint.robots[.obsidian]!
//    }()
//    private lazy var geodeRobot: Robot = {
//        blueprint.robots[.geode]!
//    }()
//
//    init(blueprint: Blueprint) {
//        self.blueprint = blueprint
//
//        self.robots = [
//            .ore: 1,
//            .clay: 0,
//            .obsidian: 0,
//            .geode: 0
//        ]
//
//        currentState = State(materialsAtEnd: materialStore, robotsAtEnd: robots, robotToBuild: nil)
//    }
//
//    private func getNextStates(from currentState: State, minsRemaining: Int) -> Set<State> {
//        let timeRemaining = 24 - minsRemaining
//        var states: Set<State> = []
//        var newRobots = currentState.robotsAtEnd
//        // Add the new robot as it is now complete
//        currentState.robotToBuild.map { newRobots[$0.miningMaterial]! += 1 }
//
//        let newMaterials = currentState.materialsAtEnd.merging(newRobots, uniquingKeysWith: { $0 + $1 })
//        let currentOreAmount = currentState.materialsAtEnd[.ore]!
//
//        // Try to build a geode robot
//        if currentState.robotsAtEnd[.obsidian]! > 0 {
//            let oreRequiredForGeodeRobot = geodeRobot.oreRequirement
//            let obsidianRequired = geodeRobot.buildMaterialRequirement!
//            let currentObsidianAmount = currentState.materialsAtEnd[.obsidian]!
//            if currentOreAmount >= oreRequiredForGeodeRobot && currentObsidianAmount >= obsidianRequired {
//                let materialRemoval: [Material: Int] = [.ore: -oreRequiredForGeodeRobot, .obsidian: -obsidianRequired]
//                let geodeRobotCreationState = State(materialsAtEnd: newMaterials.merging(materialRemoval, uniquingKeysWith: { $0 + $1 }), robotsAtEnd: newRobots, robotToBuild: blueprint.robots[.geode]!)
//                //                states.insert(State(materialsAtEnd: newMaterials.merging(materialRemoval, uniquingKeysWith: { $0 + $1 }), robotsAtEnd: newRobots, robotToBuild: blueprint.robots[.geode]!))
//
//                // If we can build a geode robot, only return that state
//                return [geodeRobotCreationState]
//            }
//        }
//
//        // Try to build an obsidian robot (only build it if there's enough time to build a geode from it's result)
//        // No point building an obsidian robot if it can't produce enough to build a geode robot
//        let obsidianRequiredForGeode = geodeRobot.buildMaterialRequirement!
//        let currentObsidianAmount = currentState.materialsAtEnd[.obsidian]!
//        let obsidianRobots = newRobots[.obsidian]!
//        let canBuildGeodeIfBuildObsidian = (currentObsidianAmount + (obsidianRobots * timeRemaining) + (timeRemaining-1)) > obsidianRequiredForGeode
//        if currentState.robotsAtEnd[.clay]! > 0 && canBuildGeodeIfBuildObsidian {
//            let oreRequiredForObsidianRobot = obsidianRobot.oreRequirement
//            let clayRequired = obsidianRobot.buildMaterialRequirement!
//            let currentClayAmount = currentState.materialsAtEnd[.clay]!
//            if currentOreAmount >= oreRequiredForObsidianRobot && currentClayAmount >= clayRequired {
//                let materialRemoval: [Material: Int] = [.ore: -oreRequiredForObsidianRobot, .clay: -clayRequired]
//                let obsidianCreationState = State(materialsAtEnd: newMaterials.merging(materialRemoval, uniquingKeysWith: { $0 + $1 }), robotsAtEnd: newRobots, robotToBuild: blueprint.robots[.obsidian]!)
//                states.insert(obsidianCreationState)
////                return [obsidianCreationState]
//            }
//        }
//
//        // Try to build a clay robot
//        // No point building a clay robot if it can't produce enough to build an obsidian
//
//        let clayRequiredForObsidian = obsidianRobot.buildMaterialRequirement!
//        let currentClayAmount = currentState.materialsAtEnd[.clay]!
//        let clayRobots = newRobots[.clay]!
//        let canBuildObsidianIfBuildClay = (currentClayAmount + (clayRobots * timeRemaining) + (timeRemaining-1)) > clayRequiredForObsidian
//        let oreRequiredForClayRobot = clayRobot.oreRequirement
//        if currentOreAmount >= oreRequiredForClayRobot && canBuildObsidianIfBuildClay {
//            let materialRemoval: [Material: Int] = [.ore: -oreRequiredForClayRobot]
//            states.insert(State(materialsAtEnd: newMaterials.merging(materialRemoval, uniquingKeysWith: { $0 + $1 }), robotsAtEnd: newRobots, robotToBuild: blueprint.robots[.clay]!))
//        }
//
//        // Try to build an ore robot
//        let oreRequiredForOreRobot = oreRobot.oreRequirement
//        if currentOreAmount >= oreRequiredForOreRobot && minsRemaining < 12 {
//            let materialRemoval: [Material: Int] = [.ore: -oreRequiredForOreRobot]
//            states.insert(State(materialsAtEnd: newMaterials.merging(materialRemoval, uniquingKeysWith: { $0 + $1 }), robotsAtEnd: newRobots, robotToBuild: blueprint.robots[.ore]!))
//        }
//
//        // Build the state where we just mine new materials
//        states.insert(State(materialsAtEnd: newMaterials, robotsAtEnd: newRobots, robotToBuild: nil))
//        return states
//    }
//
//    func beginProduction() -> Int {
//        let materialRequired: Material = .geode
//        func dfs(currentState: State, minutesElapsed: Int, geodesRetrieved: Int) -> Int {
//            if minutesElapsed == 24 { return currentState.materialsAtEnd[materialRequired]! }
//            let nextStates = getNextStates(from: currentState, minsRemaining: minutesElapsed)
//            var gr = 0
//
//            for state in nextStates {
//                let result = dfs(currentState: state, minutesElapsed: minutesElapsed + 1, geodesRetrieved: state.materialsAtEnd[materialRequired]!)
//                gr = max(gr, result)
//            }
//
//            return gr
//        }
//        let result = dfs(currentState: currentState, minutesElapsed: 0, geodesRetrieved: 0)
//        print("\(blueprint.id), \(result)")
//        return result
//    }
// }
//
// func main() throws {
//    let input: [String] = try readInput(fromTestFile: false)
//    let blueprints = input.enumerated().map { (index, line) in createBlueprint(from: line, index: index) }
//    let queue = OperationQueue()
//
//    var results: [Int] = []
//    for b in [blueprints[0], blueprints[1], blueprints[2]] {
//        let factory = RobotFactory(blueprint: b)
//        queue.addOperation({
//            results.append(factory.beginProduction())
//        })
//    }
//
//    queue.waitUntilAllOperationsAreFinished()
//
//    print(results.multiply())
// }
//
// private func createBlueprint(from line: String, index: Int) -> Blueprint {
//    let oreRegex = Regex("Each ore robot costs (\\d+) ore")
//    let clayRegex = Regex("Each clay robot costs (\\d+) ore")
//    let obsidianRegex = Regex("Each obsidian robot costs (\\d+) ore and (\\d+) (clay)")
//    let geodeRegex = Regex("Each geode robot costs (\\d+) ore and (\\d+) (obsidian)")
//
//    let oreRobot = getRobotFromRegex(oreRegex, line: line, miningMaterial: .ore)
//    let clayRobot = getRobotFromRegex(clayRegex, line: line, miningMaterial: .clay)
//    let obsidianRobot = getRobotFromRegex(obsidianRegex, line: line, miningMaterial: .obsidian)
//    let geodeRobot = getRobotFromRegex(geodeRegex, line: line, miningMaterial: .geode)
//
//    return Blueprint(id: index + 1, robots: [
//        .ore: oreRobot,
//        .clay: clayRobot,
//        .obsidian: obsidianRobot,
//        .geode: geodeRobot
//    ])
// }
//
// private func getRobotFromRegex(_ regex: Regex, line: String, miningMaterial: Material) -> Robot {
//    let matches = regex.getMatches(in: line)
//    if matches.count > 3 {
//        return Robot(buildMaterial: Material.init(rawValue: matches[3]), buildMaterialRequirement: Int(matches[2])!, oreRequirement: Int(matches[1])!, miningMaterial: miningMaterial)
//    } else {
//        return Robot(buildMaterial: nil, buildMaterialRequirement: nil, oreRequirement: Int(matches[1])!, miningMaterial: miningMaterial)
//    }
// }
//
// Timer.time(main)
