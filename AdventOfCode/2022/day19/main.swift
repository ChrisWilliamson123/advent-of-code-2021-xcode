//
//  main.swift
//  2022.19
//
//  Created by Chris Williamson on 27/12/2022.
//

import Foundation

struct Blueprint {
    let id, oreCost, clayCost, obOreCost, obClayCost, geoOreCost, geoObsCost: Int
    let maxOreRequirement, maxClayRequirement, maxObsRequirement: Int

    init(id: Int, oreCost: Int, clayCost: Int, obOreCost: Int, obClayCost: Int, geoOreCost: Int, geoObsCost: Int) {
        self.id = id
        self.oreCost = oreCost
        self.clayCost = clayCost
        self.obOreCost = obOreCost
        self.obClayCost = obClayCost
        self.geoOreCost = geoOreCost
        self.geoObsCost = geoObsCost

        self.maxOreRequirement = [oreCost, clayCost, obOreCost, geoOreCost].max()!
        self.maxClayRequirement = obClayCost
        self.maxObsRequirement = geoObsCost

    }

    func getMaxGeodesPossible(in time: Int = 24) -> Int {
        var cache: [State: Int] = [:]
        func dfs(state: State) -> Int {
            if let cached = cache[state] { return cached }
            if state.t == time { return state.g }

            var bestGeodesRetrieved: Int = 0
            let nextStates = getNextStates(from: state, using: self, endTime: time)
            for state in nextStates { bestGeodesRetrieved = max(dfs(state: state), bestGeodesRetrieved) }
            cache[state] = bestGeodesRetrieved
            return bestGeodesRetrieved
        }

        return dfs(state: State(0, 0, 0, 0, 0, 1, 0, 0, 0))
    }
}

struct State: Hashable {
    let t, o, c, ob, g, oR, cR, obR, gR: Int

    init(_ t: Int, _ o: Int, _ c: Int, _ ob: Int, _ g: Int, _ oR: Int, _ cR: Int, _ obR: Int, _ gR: Int) {
        self.t = t
        self.o = o
        self.c = c
        self.ob = ob
        self.g = g
        self.oR = oR
        self.cR = cR
        self.obR = obR
        self.gR = gR
    }

    func pruned(for blueprint: Blueprint, endTime: Int) -> State {
        if endTime == t { return self }
        let timeRemaining = endTime - t - 1
        let maxPossibleOreUse = timeRemaining * blueprint.maxOreRequirement
        let maxPossibleClayUse = timeRemaining * blueprint.maxClayRequirement
        let maxPossibleObsUse = timeRemaining * blueprint.maxObsRequirement
        return .init(t,
                     o > maxPossibleOreUse ? maxPossibleOreUse : o,
                     c > maxPossibleClayUse ? timeRemaining * maxPossibleClayUse : c,
                     ob > maxPossibleObsUse ? timeRemaining * maxPossibleObsUse : ob,
                     g,
                     oR,
                     cR,
                     obR,
                     gR)
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let blueprints = input.map {
        let regex = Regex("(\\d+)")
        let ints = regex.getGreedyMatches(in: $0).compactMap(Int.init)
        assert(ints.count == 7)
        return Blueprint(id: ints[0],
                         oreCost: ints[1],
                         clayCost: ints[2],
                         obOreCost: ints[3],
                         obClayCost: ints[4],
                         geoOreCost: ints[5],
                         geoObsCost: ints[6])
    }

    let queue = OperationQueue()
    var results: [Int] = []
    for b in blueprints {
        queue.addOperation({
            results.append(b.getMaxGeodesPossible() * b.id)
        })
    }
    queue.waitUntilAllOperationsAreFinished()
    print(results.sum())

    results.removeAll()
    for b in blueprints[0..<3] {
        queue.addOperation({
            results.append(b.getMaxGeodesPossible(in: 32))
        })
    }
    queue.waitUntilAllOperationsAreFinished()
    print(results.multiply())
}

private func getNextStates(from state: State, using blueprint: Blueprint, endTime: Int) -> Set<State> {
    let timeElapsed = state.t
    let ore = state.o
    let clay = state.c
    let obs = state.ob
    let geo = state.g
    let oreR = state.oR
    let clayR = state.cR
    let obsR = state.obR
    let geoR = state.gR
    var states: Set<State> = []
    // Try to build a geode robot, use only this state if we can build one
    if ore >= blueprint.geoOreCost && obs >= blueprint.geoObsCost {
        let state = State(timeElapsed + 1,
                          ore + oreR - blueprint.geoOreCost,
                          clay + clayR,
                          obs + obsR - blueprint.geoObsCost,
                          geo + geoR,
                          oreR,
                          clayR,
                          obsR,
                          geoR + 1).pruned(for: blueprint, endTime: endTime)
        return [state]
    }
    // Try to build an obsidian robot, use only this state if we can build one
    if obsR < blueprint.maxObsRequirement && ore >= blueprint.obOreCost && clay >= blueprint.obClayCost {
        let state = State(timeElapsed + 1,
                          ore + oreR - blueprint.obOreCost,
                          clay + clayR - blueprint.obClayCost,
                          obs + obsR,
                          geo + geoR,
                          oreR,
                          clayR,
                          obsR + 1,
                          geoR).pruned(for: blueprint, endTime: endTime)
        return [state]
    }

    // Just gather ore, no building
    let state = State(timeElapsed + 1,
                      ore + oreR,
                      clay + clayR,
                      obs + obsR,
                      geo + geoR,
                      oreR,
                      clayR,
                      obsR,
                      geoR).pruned(for: blueprint, endTime: endTime)
    states.insert(state)

    // Try to build a clay robot
    if clayR < blueprint.maxClayRequirement && ore >= blueprint.clayCost {
        let state = State(timeElapsed + 1,
                          ore + oreR - blueprint.clayCost,
                          clay + clayR,
                          obs + obsR,
                          geo + geoR,
                          oreR,
                          clayR + 1,
                          obsR,
                          geoR).pruned(for: blueprint, endTime: endTime)
        states.insert(state)
    }

    // Try to build an ore robot
    if oreR < blueprint.maxOreRequirement && ore >= blueprint.oreCost {
        let state = State(timeElapsed + 1,
                          ore + oreR - blueprint.oreCost,
                          clay + clayR,
                          obs + obsR,
                          geo + geoR,
                          oreR + 1,
                          clayR,
                          obsR,
                          geoR).pruned(for: blueprint, endTime: endTime)
        states.insert(state)
    }

    return states
}

Timer.time(main)
