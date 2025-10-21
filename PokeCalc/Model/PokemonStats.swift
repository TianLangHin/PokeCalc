//
//  PokemonStats.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

/// A struct that represents some collection of values that corresponds to a Pokémon's battle stats.
/// This struct can be used to represent base stats, effort values, individual values,
/// or in-battle values.
struct PokemonStats: Hashable {
    // Every Pokémon has these 6 values that determine their combat behaviour and effectiveness.
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    // Convenient initialiser for effort values representations.
    static var emptyEVs: PokemonStats {
        PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
    }

    // Convenient initialiser for individual values representations.
    static var emptyIVs: PokemonStats {
        PokemonStats(hp: 31, attack: 31, defense: 31, specialAttack: 31, specialDefense: 31, speed: 31)
    }

    // A convenience function to allow a step-by-step initialisation of values in the struct.
    // The use of a name to determin the edited struct field allows this progressive initialisation
    // to be conducted programmatically.
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

    // A convenience function to extract the values of each field programmatically using a string stat name.
    func getStat(name: String) -> Int {
        switch name {
        case "HP":
            return self.hp
        case "Atk":
            return self.attack
        case "Def":
            return self.defense
        case "SpA":
            return self.specialAttack
        case "SpD":
            return self.specialDefense
        case "Spe":
            return self.speed
        default:
            return 0
        }
    }
}
