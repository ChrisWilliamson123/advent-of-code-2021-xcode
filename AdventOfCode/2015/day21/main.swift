import Foundation

func main() throws {
    let boss = Player(health: 109, damage: 8, armour: 2, cost: 0)

    let itemCombinations = buildItemCombinations().sorted(by: { (lhs, rhs) in
        let totalCost: ([Item]) -> Int = { $0.reduce(0, { $0 + $1.cost }) }
        return totalCost(lhs) < totalCost(rhs)
    })

    for c in itemCombinations {
        let damage = c.reduce(0, { $0 + $1.damage })
        let armour = c.reduce(0, { $0 + $1.armour })
        let cost = c.reduce(0, { $0 + $1.cost })
        let player = Player(health: 100, damage: damage, armour: armour, cost: cost)
        let fight = Fight(playerOne: player, playerTwo: boss)
        if fight.getWinner() == player {
            print("Part one:", player.cost)
            break
        }
    }

    let combinationsByHighest = itemCombinations.reversed()
    for c in combinationsByHighest {
        let damage = c.reduce(0, { $0 + $1.damage })
        let armour = c.reduce(0, { $0 + $1.armour })
        let cost = c.reduce(0, { $0 + $1.cost })
        let player = Player(health: 100, damage: damage, armour: armour, cost: cost)
        let fight = Fight(playerOne: player, playerTwo: boss)
        if fight.getWinner() == boss {
            print("Part two:", player.cost)
            break
        }
    }
}

private func buildItemCombinations() -> [[Item]] {
    var itemCombinations: [[Item]] = []

    for w in Items.weapons {
        for a in Items.armour + [nil] {
            for r1 in Items.rings + [nil] {
                for r2 in Items.rings + [nil] {
                    if r1 != nil && r2 != nil && r2 == r1 { continue }
                    let items = [w, a, r1, r2].compactMap({ $0 })
                    itemCombinations.append(items)
                }
            }
        }
    }

    return itemCombinations
}

struct Items {
    static let weapons: [Item] = [
        .init(name: "Dagger", cost: 8, damage: 4, armour: 0),
        .init(name: "Shortsword", cost: 10, damage: 5, armour: 0),
        .init(name: "Warhammer", cost: 25, damage: 6, armour: 0),
        .init(name: "Longsword", cost: 40, damage: 7, armour: 0),
        .init(name: "Greataxe", cost: 74, damage: 8, armour: 0)
    ]

    static let armour: [Item] = [
        .init(name: "Leather", cost: 13, damage: 0, armour: 1),
        .init(name: "Chainmail", cost: 31, damage: 0, armour: 2),
        .init(name: "Splintmail", cost: 53, damage: 0, armour: 3),
        .init(name: "Bandedmail", cost: 75, damage: 0, armour: 4),
        .init(name: "Platemail", cost: 102, damage: 0, armour: 5)
    ]

    static let rings: [Item] = [
        .init(name: "Damage +1", cost: 25, damage: 1, armour: 0),
        .init(name: "Damage +2", cost: 50, damage: 2, armour: 0),
        .init(name: "Damage +3", cost: 100, damage: 3, armour: 0),
        .init(name: "Defense +1", cost: 20, damage: 0, armour: 1),
        .init(name: "Defense +2", cost: 40, damage: 0, armour: 2),
        .init(name: "Defense +3", cost: 80, damage: 0, armour: 3)
    ]
}

struct Item: Equatable {
    let name: String
    let cost: Int
    let damage: Int
    let armour: Int
}

struct Fight {
    let playerOne: Player
    let playerTwo: Player

    /// Returns the player that wins the fight
    func getWinner() -> Player {
        playerOne.numberOfTurnsToKill(playerTwo) <= playerTwo.numberOfTurnsToKill(playerOne) ? playerOne : playerTwo
    }
}

struct Player: Equatable {
    let health: Int
    let damage: Int
    let armour: Int
    let cost: Int

    func damageDealt(against player: Player) -> Int {
        max(damage - player.armour, 1)
    }

    func numberOfTurnsToKill(_ player: Player) -> Int {
        Int(ceil(Double(player.health) / Double(damageDealt(against: player))))
    }
}

Timer.time(main)
