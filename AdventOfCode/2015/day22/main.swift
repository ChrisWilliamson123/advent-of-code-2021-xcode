import Foundation

// swiftlint:disable:next cyclomatic_complexity
func main() throws {
    let boss = Boss()
    let wizard = Wizard()

    var spellsToCast: [Spell] = [
        .effect(.poison),
        .effect(.recharge),
        .effect(.shield),
        .effect(.poison),
        .effect(.recharge),
        .drain,
        .effect(.poison),
        .magicMissile,
        .magicMissile
    ]

    var activeEffects: [Effect] = []

    var turn = 0
    var manaSpent = 0
    while boss.health > 0 && wizard.health > 0 {
        // Remove 1 hp from player
        if turn % 2 == 0 { wizard.health -= 1 }
        if wizard.health <= 0 {
            print("Auto health loss killed Wizard")
            break
        }

        // Apply each effect
        for effect in activeEffects {
            effect.applyTo(wizard: wizard, boss: boss)
        }
        // Remove expired effects
        activeEffects.removeAll(where: { $0.duration == 0 })

        if boss.health <= 0 {
            break
        }

        if turn % 2 == 0 {
            let spell = spellsToCast.removeFirst()
            wizard.mana -= spell.cost
            manaSpent += spell.cost
            assert(wizard.mana >= 0, "Wizard has run out of mana!")
            switch spell {
            case .magicMissile:
                boss.health -= 4
            case .drain:
                boss.health -= 2
                wizard.health += 2
            case .effect(let effectType):
                if case .shield = effectType {
                    wizard.armour += 7
                }
                assert(!activeEffects.contains(where: {
                    if case effectType = $0.type {
                        return true
                    }
                    return false
                }), "Trying to stack same effect")
                activeEffects.append(.init(type: effectType, duration: effectType.initialDuration))
            }
            print(manaSpent)
        } else {
            wizard.health -= boss.damageDealt(against: wizard)
        }

        turn += 1
    }

    print(wizard.health, boss.health, manaSpent)
}

Timer.time(main)

class Effect: CustomStringConvertible {
    let type: EffectType
    var duration: Int

    var description: String {
        "\(type) - \(duration)"
    }

    init(type: EffectType, duration: Int) {
        self.type = type
        self.duration = duration
    }

    func applyTo(wizard: Wizard, boss: Boss) {
        switch self.type {
        case .recharge: wizard.mana += 101
        case .poison: boss.health -= 3
        case .shield where duration == 1: wizard.armour -= 7
        case .shield: break
        }
        duration -= 1
    }

}

enum EffectType {
    case shield
    case poison
    case recharge

    var initialDuration: Int {
        switch self {
        case .shield: return 6
        case .poison: return 6
        case .recharge: return 5
        }
    }

    var cost: Int {
        switch self {
        case .shield:
            return 113
        case .poison:
            return 173
        case .recharge:
            return 229
        }
    }
}

enum Spell {
    case magicMissile
    case drain
    case effect(EffectType)

    var cost: Int {
        switch self {
        case .magicMissile:
            return 53
        case .drain:
            return 73
        case .effect(let effect):
            return effect.cost
        }
    }

    var damage: Int {
        switch self {
        case .magicMissile:
            return 4
        case .drain:
            return 2
        case .effect:
            return 0
        }
    }

    var heal: Int {
        if case .drain = self {
            return 2
        }
        return 0
    }
}

class Wizard {
    var health: Int = 50
    var mana: Int = 500
    var armour: Int = 0

    func damageDealt(against boss: Boss, withSpell spell: Spell) -> Int {
        spell.damage
    }
}

class Boss {
    var health: Int = 51
    let damage: Int = 9

    func damageDealt(against wizard: Wizard) -> Int {
        max(damage - wizard.armour, 1)
    }
}
