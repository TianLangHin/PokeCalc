//
//  CalculationViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 18/10/2025.
//

import SwiftUI

/// This ViewModel carries out the Pokemon damage calculation logic,
/// facilitating one of the main functionalities of the app.
@Observable
class CalculationViewModel {
    /// The main useful function of this ViewModel. When given a particular move,
    /// as well as the custom (`Pokemon` struct) and base (`BattleData` struct) information
    /// about the attacking and defending Pokemon, it will return how much damage (HP%) is dealt
    /// as well as the category of type effectiveness that it belongs to.
    /// The logic here is domain-specific to Pokemon core series games,
    /// and are pivotal to casual gameplay and competitive games.
    func calculateDamage(
        move: String,
        attacker: Pokemon,
        attackerData: BattleDataFetcher.BattleData,
        defender: Pokemon,
        defenderData: BattleDataFetcher.BattleData) async -> (Double, Effectiveness)? {

        // First, the combat data of the move used is retrieved.
        guard let moveData = await getMoveData(move: move) else {
            return nil
        }
        // Next, the relevant type relations of the move are retrieved.
        // This is used both in damage calculation and in directly returning the move effectiveness.
        guard let typeData = await getTypeData(typeUrl: moveData.type.url) else {
            return nil
        }
        // Some moves have a `power` of `nil`, which means they are non-damaging.
        // No more calculation needs to be done here.
        guard let basePower = moveData.power else {
            return (0, .immune)
        }

        // Next, the in-combat values of the Pokemon's stats are calculated.
        // (which are found from the customised stats and the base data from the API)
        let attackerStats = battleStats(pokemon: attacker, pokemonData: attackerData)
        let defenderStats = battleStats(pokemon: defender, pokemonData: defenderData)

        // The effective attacking stat and defending stat are then retrieved.
        var attack = moveData.damageClass.name == "physical" ? attackerStats.attack : attackerStats.specialAttack
        if move == "body-press" {
            attack = attackerStats.defense
        }
        let defense = moveData.damageClass.name == "physical" ? defenderStats.defense : defenderStats.specialDefense

        // The base damage is calculated using the Pokémon damage formula,
        // listed in https://bulbapedia.bulbagarden.net/wiki/Damage#Generation_V_onward
        let baseDamage = (((2 * attacker.level) / 5 + 2) * basePower * (attack / defense)) / 50 + 2

        // The two multipliers considered in this app are the same type attack bonus (STAB) and type effectiveness.
        let stab = !attackerData.types.allSatisfy { type in type.0 != moveData.type.name }
        let typeEffect = typeEffectiveness(attacker: typeData, defender: defenderData.types.map { $0.0 })

        // The final damage is calculated, and then the returned value is the percentage of max HP dealt.
        let finalDamage = Double(baseDamage) * (stab ? 1.5 : 1) * (typeEffect?.multiplier() ?? 1)
        let opponentHP = defenderStats.hp

        // The type effectiveness is also returned as the second element of the tuple.
        return (min(finalDamage / Double(opponentHP), 1.0), typeEffect ?? .neutral)
    }

    /// This function (used both within this class and outside of it)
    /// calculates the effective combat stats of a Pokemon based of its customisations and base data.
    func battleStats(pokemon: Pokemon, pokemonData: BattleDataFetcher.BattleData) -> PokemonStats {
        var battleStats = PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)

        // The HP stat is calculated slightly differently from the others.
        let intPortion: Int = 2 * pokemonData.stats.hp + 31 + pokemon.effortValues.hp / 4
        battleStats.addStat(name: "HP", value: ((intPortion * pokemon.level) / 100) + pokemon.level + 10)

        // This order allows the correspondence with the `POKEMON_NATURES` convention.
        // Having an index `i` such that `i / 5 = 1` means enhancing Def, while `i % 5 = 3` means reducing SpD.
        let stats = ["Atk", "Def", "SpA", "SpD", "Spe"]

        // The order of the natures in the global `POKEMON_NATURES` list indicates exactly
        // which stat needs to be enhanced or reduced, purely based off its index in the list.
        // Since this corresponds to two numbers from 0-4 each, if an invalid nature is found then
        // a value outside is range is provided (as it will not trigger any additional enhancements or reductions).
        let (enhance, reduce) = POKEMON_NATURES.firstIndex(of: pokemon.nature).map { idx in (idx / 5, idx % 5) } ?? (5, 5)

        for (index, stat) in stats.enumerated() {
            // To calculate the effective combat stat, the nature boost/reduction,
            // base stat, and effort value are needed.
            let natureChange = enhance == reduce ? 1 : index == enhance ? 1.1 : index == reduce ? 0.9 : 1
            let base = pokemonData.stats.getStat(name: stat)
            let ev = pokemon.effortValues.getStat(name: stat)
            // This formula is used for all core series game calculations and is domain-specific.
            let intPortion: Int = (2 * base + 31 + ev / 4) * pokemon.level
            battleStats.addStat(name: stat, value: Int(Double(intPortion / 100 + 5) * natureChange))
        }

        return battleStats
    }

    /// This function retrieves the information about a particular move from PokéAPI.
    /// This is not delegated to a separate struct since damage calculation is the only place here
    /// where the data requested here is needed.
    func getMoveData(move: String) async -> MoveData? {
        let jsonDecoder = JSONDecoder()
        let endpoint = URL(string: "https://pokeapi.co/api/v2/move/\(move)")
        guard let url = endpoint else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        // The MoveData struct is defined at the bottom of this class,
        // and is used to align with the returned JSON format.
        guard let data = try? jsonDecoder.decode(MoveData.self, from: response) else {
            return nil
        }
        return data
    }

    /// This function retrieves the type interaction information about a particular type from PokéAPI.
    /// This is not delegated to a separate struct since damage calculation is the only place here
    /// where the data requested here is needed.
    func getTypeData(typeUrl: URL) async -> TypeData? {
        let jsonDecoder = JSONDecoder()
        guard let (response, _) = try? await URLSession.shared.data(from: typeUrl) else {
            return nil
        }
        // The TypeData struct is defined at the bottom of this class,
        // and is used to align with the returned JSON format.
        guard let data = try? jsonDecoder.decode(TypeData.self, from: response) else {
            return nil
        }
        return data
    }

    // Convenience function to calculate the type effectiveness of a single-typed move
    // against a potentially dual-typed Pokemon.
    func typeEffectiveness(attacker: TypeData, defender: [String]) -> Effectiveness? {
        var effectiveness: Effectiveness = .neutral
        for defendingType in defender {
            // The convenience functions defined in the `Effectiveness` enum allow
            // an iteration over all the defending types to finally determine the type effectiveness.
            if attacker.damageRelations.doubleDamageTo.contains(where: { $0.name == defendingType }) {
                effectiveness = effectiveness.addWeak()
            } else if attacker.damageRelations.halfDamageTo.contains(where: { $0.name == defendingType }) {
                effectiveness = effectiveness.addResist()
            } else if attacker.damageRelations.noDamageTo.contains(where: { $0.name == defendingType }) {
                effectiveness = effectiveness.addImmune()
            }
        }
        return effectiveness
    }

    // This enum covers all the possible type interactions in a Pokemon.
    enum Effectiveness {
        case neutral
        case weak
        case resist
        case doubleWeak
        case doubleResist
        case immune

        // The addWeak, addResist, and addImmune functions allow an iterative way
        // of calculating the final type interaction, rather than needing to make a large lookup table.

        func addWeak() -> Self {
            // A new weakness will cancel out a resistance and exacerbate a weakness.
            switch self {
            case .neutral:
                return .weak
            case .weak, .doubleWeak:
                return .doubleWeak
            case .resist:
                return .neutral
            case .doubleResist:
                return .resist
            case .immune:
                return .immune
            }
        }

        func addResist() -> Self {
            // A new resistance will cancel out a weakness and bolster a resistance.
            switch self {
            case .neutral:
                return .resist
            case .resist, .doubleResist:
                return .doubleResist
            case .weak:
                return .neutral
            case .doubleWeak:
                return .weak
            case .immune:
                return .immune
            }
        }

        func addImmune() -> Self {
            // An immunity automatically disregards other modifiers and makes the Pokemon immune to the type.
            return .immune
        }

        // Returns the multiplier to be applied to the final damage due to type effectiveness.
        func multiplier() -> Double {
            switch self {
            case .neutral:
                return 1
            case .weak:
                return 2
            case .resist:
                return 0.5
            case .doubleWeak:
                return 4
            case .doubleResist:
                return 0.25
            case .immune:
                return 0
            }
        }
    }

    // This struct decodes and parses the data relating to a Pokemon move returned from PokéAPI.
    struct MoveData: Codable {
        let damageClass: RawDamageData
        let power: Int?
        let type: RawTypeData

        enum CodingKeys: String, CodingKey {
            case damageClass = "damage_class"
            case power = "power"
            case type = "type"
        }

        struct RawDamageData: Codable {
            let name: String
        }

        struct RawTypeData: Codable {
            let name: String
            let url: URL
        }
    }

    // This struct decodes and parses the data relating to a Pokemon type
    // and its damage relations as returned from PokéAPI.
    struct TypeData: Codable {
        let damageRelations: RawDamageRelationsData

        enum CodingKeys: String, CodingKey {
            case damageRelations = "damage_relations"
        }

        struct RawDamageRelationsData: Codable {
            let doubleDamageTo: [RawTypeNameData]
            let halfDamageTo: [RawTypeNameData]
            let noDamageTo: [RawTypeNameData]

            enum CodingKeys: String, CodingKey {
                case doubleDamageTo = "double_damage_to"
                case halfDamageTo = "half_damage_to"
                case noDamageTo = "no_damage_to"
            }
        }

        struct RawTypeNameData: Codable {
            let name: String
        }
    }
}
