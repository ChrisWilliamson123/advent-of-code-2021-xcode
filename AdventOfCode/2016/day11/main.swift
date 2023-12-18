import Foundation
import Algorithms

enum Entity: Hashable, CustomStringConvertible {
    case generator(element: String)
    case chip(element: String)

    var description: String {
        switch self {
        case .generator(let element):
            return element + "G"
        case .chip(let element):
            return element + "M"
        }
    }

    var element: String {
        switch self {
        case .generator(let element):
            return element
        case .chip(let element):
            return element
        }
    }

}

struct Floor: Hashable, CustomStringConvertible {
    let entities: Set<Entity>

    var description: String {
        entities.map({ $0.description }).joined(separator: ", ")
    }

    var generators: Set<Entity> {
        entities.reduce(into: [], { if case .generator = $1 { $0.insert($1) } })
    }

    var chips: Set<Entity> {
        entities.reduce(into: [], { if case .chip = $1 { $0.insert($1) } })
    }
}

struct State: Hashable {
    let currentFloor: Int
    let floors: [Floor]

    var floor: Floor { floors[currentFloor] }
    var isComplete: Bool {
        floors[0].entities.isEmpty &&
        floors[1].entities.isEmpty &&
        floors[2].entities.isEmpty
    }
}

private let FLOOR_RANGE = 0...3

func main() throws {
    let input: [String] = try readInput(fromTestFile: true)
    let floors = buildFloors(input: input)

//    let currentState = State(currentFloor: 0, floors: floors)
//    let nextStates = getNextStates(from: currentState)
//    for state in nextStates {
//        print("Floor: \(state.currentFloor)")
//        print("Floors:")
//        for f in state.floors {
//            print("\t\(f.description)")
//        }
//    }

    let currentState = State(currentFloor: 0, floors: floors)

    var cache: [State: Int] = [:]

    func bfs(state: State, seen: Set<State>, depth: Int = 0) -> Int {
//        print(depth)
        if let cached = cache[state] {
            return cached
        }
//        if seen.contains(state) {
//            return Int.max
//        }
        if state.isComplete {
//            print("Complete", state, depth)
            return depth
        }
        var best = Int.max
        let nextStates = getNextStates(from: state, seen: seen)
        if nextStates.isEmpty { return best }
        for nextState in nextStates {
            let result = bfs(state: nextState, seen: Set(seen.union([state])), depth: depth + 1)
            best = min(result, best)
        }
        cache[state] = best
//        print(state, best)
        return best
    }

    print(bfs(state: currentState, seen: []))
}

private func isStateValid(_ state: State) -> Bool {
    if !FLOOR_RANGE.contains(state.currentFloor) {
        return false
    }

    for floor in state.floors {
        let generators = floor.generators
        if generators.isEmpty { continue }
        let chips = floor.chips
        let generatorElements = generators.map { $0.element }
        let safeChips = chips.filter({ generatorElements.contains($0.element) })
        if safeChips.count != chips.count {
            return false
        }
    }
    return true
}

private func getNextStates(from currentState: State, seen: Set<State>) -> Set<State> {
    var states: Set<State> = []
    let upFloor = currentState.currentFloor + 1
    let downFloor = currentState.currentFloor - 1

    states.insert(State(currentFloor: upFloor, floors: currentState.floors))
    states.insert(State(currentFloor: downFloor, floors: currentState.floors))

    let itemPermutations = currentState.floor.entities.permutations(ofCount: 2)
    for p in itemPermutations {
        let newCurretFloorEntites = currentState.floor.entities.subtracting(Set(p))
        if upFloor < 4 {
            let newUpFloorEntites = currentState.floors[upFloor].entities.union(Set(p))
            var allEntites = currentState.floors.map { $0.entities }
            allEntites[currentState.currentFloor] = newCurretFloorEntites
            allEntites[upFloor] = newUpFloorEntites
            let newFloors = allEntites.map { Floor(entities: $0) }
            states.insert(State(currentFloor: upFloor, floors: newFloors))
        }
        if downFloor > 0 {
            let newDownFloorEntities = currentState.floors[downFloor].entities.union(Set(p))
            var allEntites = currentState.floors.map { $0.entities }
            allEntites[currentState.currentFloor] = newCurretFloorEntites
            allEntites[downFloor] = newDownFloorEntities
            let newFloors = allEntites.map { Floor(entities: $0) }
            states.insert(State(currentFloor: downFloor, floors: newFloors))
        }
    }

    for item in currentState.floor.entities {
        let newCurretFloorEntites = currentState.floor.entities.subtracting([item])
        if upFloor < 4 {
            let newUpFloorEntites = currentState.floors[upFloor].entities.union([item])
            var allEntites = currentState.floors.map { $0.entities }
            allEntites[currentState.currentFloor] = newCurretFloorEntites
            allEntites[upFloor] = newUpFloorEntites
            let newFloors = allEntites.map { Floor(entities: $0) }
            states.insert(State(currentFloor: upFloor, floors: newFloors))
        }
        if downFloor > 0 {
            let newDownFloorEntities = currentState.floors[downFloor].entities.union([item])
            var allEntites = currentState.floors.map { $0.entities }
            allEntites[currentState.currentFloor] = newCurretFloorEntites
            allEntites[downFloor] = newDownFloorEntities
            let newFloors = allEntites.map { Floor(entities: $0) }
            states.insert(State(currentFloor: downFloor, floors: newFloors))
        }
    }
    return states.filter({ isStateValid($0) }).subtracting(seen)
}

private func buildFloors(input: [String]) -> [Floor] {
    input.map({
        let chips = Regex("(\\w+)-compatible").getGreedyMatches(in: $0).map { chip in
            Entity.chip(element: chip.components(separatedBy: "-")[0][0].uppercased())
        }
        let generators = Regex("\\w+ generator").getGreedyMatches(in: $0).map { generator in
            Entity.generator(element: generator.components(separatedBy: " ")[0][0].uppercased())
        }
        return Floor(entities: Set(chips + generators))
    })
}

Timer.time(main)
