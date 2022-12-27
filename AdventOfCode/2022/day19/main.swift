//
//  main.swift
//  2022.19
//
//  Created by Chris Williamson on 27/12/2022.
//

import Foundation

struct Blueprint {
    let id: Int
    let oreCost: Int
    let clayCost: Int
    let obOreCost: Int
    let obClayCost: Int
    let geoOreCost: Int
    let geoObsCost: Int

    var maxOreRequirement: Int { [oreCost, clayCost, obOreCost, geoOreCost].max()! }
    var maxClayRequirement: Int { obClayCost }
    var maxObsRequirement: Int { geoObsCost }
}

// STATE
// [ timeElapsed, ore, clay, obs, geo, oreR, clayR, obsR, geoR ]
typealias State = [Int]
func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let blueprints = input.map {
        let regex = Regex("(\\d+)")
        let ints = regex.getGreedyMatches(in: $0).compactMap(Int.init)
        assert(ints.count == 7)
        return Blueprint(id: ints[0], oreCost: ints[1], clayCost: ints[2], obOreCost: ints[3], obClayCost: ints[4], geoOreCost: ints[5], geoObsCost: ints[6])
    }

    let queue = OperationQueue()

    var results: [Int] = []
    for b in blueprints {
        var cache: [State: Int] = [:]
        func dfs(state: State, endTime: Int = 24) -> Int {
            if let cached = cache[state] { return cached }
            let (timeElapsed, ore, clay, obs, geo, oreR, clayR, obsR, geoR) = destructureState(state)
            if timeElapsed == endTime { return geo }

            var bestGeodesRetrieved = 0
            let nextStates = getNextStates(from: state, using: b)
            for state in nextStates {
                let result = dfs(state: state, endTime: endTime)
                bestGeodesRetrieved = max(result, bestGeodesRetrieved)
            }
            cache[state] = bestGeodesRetrieved
            return bestGeodesRetrieved
        }

        let initialState = [0, 0, 0, 0, 0, 1, 0, 0, 0]
        queue.addOperation({
            let result = dfs(state: initialState)
            print("Blueprint \(b.id):", result)
            results.append(result * b.id)
        })
    }

    queue.waitUntilAllOperationsAreFinished()

    print(results.sum())
}

private func getNextStates(from state: [Int], using blueprint: Blueprint) -> Set<State> {
    /**
     THERES NO USE IN HAVING MORE OF A MATERIAL THAN WHAT THE GREEDIEST ROBOT CAN USE
        Therefore if we have excess materials, we can just reduce them down to the maximum needed?
     THERES ALSO NO USE IN HAVING MORE ROBOTS THAN THE NUMBER OF MATERIALS WE CAN USE
     */
    let (timeElapsed, ore, clay, obs, geo, oreR, clayR, obsR, geoR) = destructureState(state)
    var states: Set<State> = []
    // just gather ore
    states.insert([timeElapsed + 1, ore + oreR, clay + clayR, obs + obsR, geo + geoR, oreR, clayR, obsR, geoR])

    // Try to build each robot
    // ore
    if oreR < blueprint.maxOreRequirement && ore >= blueprint.oreCost {
        states.insert([timeElapsed + 1, ore + oreR - blueprint.oreCost, clay + clayR, obs + obsR, geo + geoR, oreR + 1, clayR, obsR, geoR])
    }
    // clay
    if clayR < blueprint.maxClayRequirement && ore >= blueprint.clayCost {
        states.insert([timeElapsed + 1, ore + oreR - blueprint.clayCost, clay + clayR, obs + obsR, geo + geoR, oreR, clayR + 1, obsR, geoR])
    }
    // obsidian
    if obsR < blueprint.maxObsRequirement && ore >= blueprint.obOreCost && clay >= blueprint.obClayCost {
        states.insert([timeElapsed + 1, ore + oreR - blueprint.obOreCost, clay + clayR - blueprint.obClayCost, obs + obsR, geo + geoR, oreR, clayR, obsR + 1, geoR])
    }
    // geode
    if ore >= blueprint.geoOreCost && obs >= blueprint.geoObsCost {
        // If we can build a geode robot, always do that
        let state = [timeElapsed + 1, ore + oreR - blueprint.geoOreCost, clay + clayR, obs + obsR - blueprint.geoObsCost, geo + geoR, oreR, clayR, obsR, geoR + 1]
//        return [state]
        states.insert(state)
    }

    return states
}

private func destructureState(_ state: [Int]) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int) {
    return (state[0], state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8])
}

Timer.time(main)
