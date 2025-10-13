//
//  PokemonStats.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

struct PokemonStats: Hashable {
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    static var emptyEVs: PokemonStats {
        PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
    }

    static var emptyIVs: PokemonStats {
        PokemonStats(hp: 31, attack: 31, defense: 31, specialAttack: 31, specialDefense: 31, speed: 31)
    }

    mutating func addStat(name: String, value: Int) {
        switch name {
        case "HP":
            self.hp = value
        case "Atk":
            self.attack = value
        case "Def":
            self.defense = value
        case "SpA":
            self.specialAttack = value
        case "SpD":
            self.specialDefense = value
        case "Spe":
            self.speed = value
        default:
            break
        }
    }
}
