import Foundation

class Grove {
    private static let PROPOSALS: [[Coordinate]] = [
        [.init(0, -1), .init(-1, -1), .init(1, -1)], // N, NE, NW
        [.init(0, 1), .init(-1, 1), .init(1, 1)], // S, SE, SW
        [.init(-1, 0), .init(-1, -1), .init(-1, 1)], // W, NW, SW
        [.init(1, 0), .init(1, -1), .init(1, 1)] // E, NE, SE
    ]
    private var elfCoords: Set<Coordinate>

    init(elfCoords: Set<Coordinate>) {
        self.elfCoords = elfCoords
    }

    func moveElves() {
        for roundIndex in 0..<Int.max {
            let new = getNextPositions(roundIndex: roundIndex)
            if new == elfCoords {
                print(roundIndex + 1)
                break
            }
            elfCoords = new
            if roundIndex == 9 {
                print(getScore())
            }
        }
    }

    func getNextPositions(roundIndex: Int) -> Set<Coordinate> {
        let proposalStartIndex = roundIndex % 4
        var newElfPositions: Set<Coordinate> = []
        var propositions: [Coordinate: Coordinate] = [:]
        for elf in elfCoords {
            let adjacentCoords: Set<Coordinate> = elf.adjacents.reduce(into: [], { $0.insert($1) })
            let adjacentElves = adjacentCoords.intersection(elfCoords)

            // No adjacent elves so move on to next elf
            if adjacentElves.isEmpty {
                continue
            }

            // Propose moves
            for i in 0..<4 {
                let proposalCoords = Self.PROPOSALS[(proposalStartIndex + i) % 4]
                let adjacentCoordsToCheck = proposalCoords.map({ $0 + elf })
                if adjacentElves.intersection(adjacentCoordsToCheck).isEmpty {
                    propositions[elf] = elf + proposalCoords[0]
                    break
                }
            }
        }

        // Go through each elf and move it if it's the only one to propose a new position
        let propositionValueCounts = propositions.reduce(into: [Coordinate: Int](), {
            $0[$1.value] = ($0[$1.value] ?? 0) + 1
        })

        for elf in elfCoords {
            if let proposed = propositions[elf], propositionValueCounts[proposed] == 1 {
                newElfPositions.insert(proposed)
            } else {
                newElfPositions.insert(elf)
            }
        }

        assert(newElfPositions.count == elfCoords.count)
        return newElfPositions
    }

    private func getScore() -> Int {
        let minY = elfCoords.min(by: { $0.y < $1.y })!.y
        let maxY = elfCoords.max(by: { $0.y < $1.y })!.y
        let minX = elfCoords.min(by: { $0.x < $1.x })!.x
        let maxX = elfCoords.max(by: { $0.x < $1.x })!.x

        return ((maxY+1-minY)*(maxX+1-minX)) - elfCoords.count
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    var elfCoords: Set<Coordinate> = []
    for y in 0..<input.count {
        for x in 0..<input[y].count where input[y][x] == "#" {
            elfCoords.insert(Coordinate(x, y))
        }
    }

    let grove = Grove(elfCoords: elfCoords)
    grove.moveElves()
}

Timer.time(main)
