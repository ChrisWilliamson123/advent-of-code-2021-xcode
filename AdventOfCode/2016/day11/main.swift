import Foundation

func main() throws {
    //    let input: [String] = try readInput(fromTestFile: true)

    // Test floors
    // H = 1, G = 2
//    let floors: [Building.Floor] = [
//        .init(id: 0, components: [-1, -2]),
//        .init(id: 1, components: [1]),
//        .init(id: 2, components: [2]),
//        .init(id: 3, components: []),
//    ]
//    let target = Building(elevatorFloor: 3, floors: [
//        .init(id: 0, components: []),
//        .init(id: 1, components: []),
//        .init(id: 2, components: []),
//        .init(id: 3, components: [-1, -2, 1, 2]),
//    ])

    let floors: [Building.Floor] = [
        .init(id: 0, components: [2, -2, 4, -4]),
        .init(id: 1, components: [1, -1, 3, -3, 5]),
        .init(id: 2, components: [-5]),
        .init(id: 3, components: []),
    ]
    let target = Building(elevatorFloor: 3, floors: [
        .init(id: 0, components: []),
        .init(id: 1, components: []),
        .init(id: 2, components: []),
        .init(id: 3, components: [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]),
    ])

    let building = Building(floors: floors)

    let result = dijkstra(graph: [building],
                       source: building,
                       target: target,
                       getNeighbours: {
        let ns = $0.possibleNextStates
        return ns

    }) { _, _ in
        1
    }

    print(result.distances[target])

//    print(result.chain[target]??.printBuilding())
    target.printBuilding()
    print("\n")
    var prev = result.chain[target]
//    prev!!.printBuilding()
    while prev != nil {
        print("\n")
        prev!!.printBuilding()
        prev = result.chain[prev!!]
    }
}

struct Building: Hashable {

    var elevatorFloor: Int = 0
    var floors: [Floor]

    var possibleNextStates: Set<Building> {
        let unrestrictedMoves = getUnrestrictedMoves()

        var finalMoves: Set<Move> = []
        for unrestrictedMove in unrestrictedMoves {
            let nextFloorComponents = floors[unrestrictedMove.floor].components
            let generatorsOnNextFloor = nextFloorComponents.filter({ $0 > 0 })
            let chipsOnNextFloor = nextFloorComponents.filter({ $0 < 0 })

            switch unrestrictedMove.components.count {
            case 1:
                // It's either a gen or a mic
                let component = unrestrictedMove.components[0]
                let isGenerator = component > 0
                // If it's a generator, we can only move it if the next floor is empty OR it has one item AND the one item is the generator's microchip
                if isGenerator && (nextFloorComponents.isEmpty || (nextFloorComponents.count == 1 && nextFloorComponents.first! == component * -1 )) {
                    finalMoves.insert(unrestrictedMove)
                }

                // If it's a microchip, we can move it if there's no generators on the next floor or there's the correct gen for the chip
                if !isGenerator && (generatorsOnNextFloor.count == 0 || generatorsOnNextFloor.contains(component * -1)) {
                    finalMoves.insert(unrestrictedMove)
                }
            case 2:
                // It's either two gens, two chips or one of each
                let first = unrestrictedMove.components[0]
                let second = unrestrictedMove.components[1]
                let firstIsGen = first > 0
                let secondIsGen = second > 0

                switch (firstIsGen, secondIsGen) {
                case (false, false):
                    // Both are microchips, can only move them if there's no generators on the next floor OR both generators exist on the next floor
                    if generatorsOnNextFloor.count == 0 || (generatorsOnNextFloor.contains(first * -1) && generatorsOnNextFloor.contains(second * -1)) {
                        finalMoves.insert(unrestrictedMove)
                    }
                case (false, true), (true, false):
                    // If they're a match, move them if it won't fry existing microchips on next floor
                    if first == second * -1 {
                        if chipsOnNextFloor.count == 0 { finalMoves.insert(unrestrictedMove) }
                        else {
                            let chipIsSafe: (Int) -> Bool = { chip in generatorsOnNextFloor.contains(chip * -1) }
                            let safeChipsOnNextFloor = chipsOnNextFloor.filter({ chipIsSafe($0) })
                            if safeChipsOnNextFloor.count == chipsOnNextFloor.count {
                                finalMoves.insert(unrestrictedMove)
                            }
                        }
                    }
                case (true, true):
                    // Both are gens, can move them up if there's no microchips on next floor OR if the only microchips are thr ones supported by the gens
                    if chipsOnNextFloor.count == 0 || (chipsOnNextFloor.filter({ $0 != first * -1 && $0 != second * -1 }).count == 0) {
                        finalMoves.insert(unrestrictedMove)
                    }
                }
            default: assert(false)
            }




        }
        if let optimal = finalMoves.first(where: { $0.components.count == 2 && $0.components[0] < 0 && $0.components[1] < 0 }) {
            return [buildNewBuilding(from: optimal)]
        }
        return finalMoves.reduce(into: [], { $0.insert(buildNewBuilding(from: $1)) })
    }

    private func buildNewBuilding(from move: Move) -> Building {
        _ = floors
        var newFloors = floors
        let newElevatorFloor = move.floor

        // Remove the components of the move from the current floor and add them to the new floor
        for componentToMove in move.components {
            newFloors[elevatorFloor].components.remove(componentToMove)
            newFloors[newElevatorFloor].components.insert(componentToMove)
        }

        return .init(elevatorFloor: newElevatorFloor, floors: newFloors)
    }

    private func getUnrestrictedMoves() -> [Move] {
        let possibleNextFloorsForElevator = [max(0, elevatorFloor-1), min(floors.count - 1, elevatorFloor + 1)].filter({ $0 != elevatorFloor })

        // Get a full list of possible moves, ignoring rules
        let componentsOnCurrentFloor = Array(floors[elevatorFloor].components)
        var componentMoves: [[Int]] = []
        componentMoves.append([componentsOnCurrentFloor[0]])
        for i in 1..<componentsOnCurrentFloor.count {
            componentMoves.append([componentsOnCurrentFloor[i-1], componentsOnCurrentFloor[i]])
            componentMoves.append([componentsOnCurrentFloor[i]])
        }

        var unrestrictedMoves: [Move] = []
        for cm in componentMoves {
            for f in possibleNextFloorsForElevator {
                unrestrictedMoves.append(Move(floor: f, components: cm))
            }
        }

        return unrestrictedMoves
    }

    struct Floor: Hashable {
        let id: Int
        var components: Set<Int>
    }

    struct Move: Hashable, CustomStringConvertible { let floor: Int, components: [Int]; var description: String { "Floor: \(floor), Comps: \(components)" }  }

    func printBuilding() {
        let map: [Int: String] = [
            -1: "HM",
             -2: "LM",
             1: "HG",
             2: "LG",
        ]
        var lines: [String] = []
        for i in 0..<floors.count {
//            lines.append("F\(i+1)\t\(elevatorFloor == i ? "E" : " ")\t\(floors[i].components.sorted().joined(separator: "\t"))")
            lines.append("F\(i+1)\t\(elevatorFloor == i ? "E" : " ")\t\(floors[i].components.sorted().reduce("", { $0 + "\(map[$1]!)\t" }))")
        }
        lines.reverse()
        for l in lines { print(l) }
    }
}

try main()
