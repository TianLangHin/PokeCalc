//
//  CalculationViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 18/10/2025.
//

import SwiftUI

@Observable
class CalculationViewModel {
    let battleDataFetcher = BattleDataFetcher()

    func calculateDamage(
        move: String,
        attacker: Pokemon,
        attackerData: BattleDataFetcher.BattleData,
        defender: Pokemon,
        defenderData: BattleDataFetcher.BattleData) async -> Double? {

        guard let moveData = await getMoveData(move: move) else {
            return nil
        }
        guard let typeData = await getTypeData(typeUrl: moveData.type.url) else {
            return nil
        }
        guard let basePower = moveData.power else {
            return 0
        }

        let attackerStats = battleStats(pokemon: attacker, pokemonData: attackerData)
        let defenderStats = battleStats(pokemon: defender, pokemonData: defenderData)

        var attack = moveData.damageClass.name == "physical" ? attackerStats.attack : attackerStats.specialAttack
        if move == "body-press" {
            attack = attackerStats.defense
        }
        let defense = moveData.damageClass.name == "physical" ? defenderStats.defense : defenderStats.specialDefense

        let baseDamage = (((2 * attacker.level) / 5 + 2) * basePower * (attack / defense)) / 50 + 2
        let stab = !attackerData.types.allSatisfy { type in type.0 != moveData.type.name }
        let typeEffect = typeEffectiveness(attacker: typeData, defender: defenderData.types.map { $0.0 })

        let finalDamage = Double(baseDamage) * (stab ? 1.5 : 1) * (typeEffect?.multiplier() ?? 1)
        let opponentHP = defenderStats.hp

        return min(finalDamage / Double(opponentHP), 1.0)
    }

    func battleStats(pokemon: Pokemon, pokemonData: BattleDataFetcher.BattleData) -> PokemonStats {
        var battleStats = PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)

        let intPortion: Int = 2 * pokemonData.stats.hp + 31 + pokemon.effortValues.hp / 4
        battleStats.addStat(name: "HP", value: ((intPortion * pokemon.level) / 100) + pokemon.level + 10)

        let stats = ["Atk", "Def", "SpA", "SpD", "Spe"]
        let (enhance, reduce) = POKEMON_NATURES.firstIndex(of: pokemon.nature).map { idx in (idx / 5, idx % 5) } ?? (5, 5)
        for (index, stat) in stats.enumerated() {
            let natureChange = enhance == reduce ? 1 : index == enhance ? 1.1 : index == reduce ? 0.9 : 1
            let base = pokemonData.stats.getStat(name: stat)
            let ev = pokemon.effortValues.getStat(name: stat)
            let intPortion: Int = (2 * base + 31 + ev / 4) * pokemon.level
            battleStats.addStat(name: stat, value: Int(Double(intPortion / 100 + 5) * natureChange))
        }

        return battleStats
    }

    private func damageFormula(level: Int, power: Int, atk: Int, def: Int) -> Int {
        return (((2 * level) / 5 + 2) * power * atk / def) / 50 + 2
    }

    func getMoveData(move: String) async -> MoveData? {
        let jsonDecoder = JSONDecoder()
        let endpoint = URL(string: "https://pokeapi.co/api/v2/move/\(move)")
        guard let url = endpoint else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        guard let data = try? jsonDecoder.decode(MoveData.self, from: response) else {
            return nil
        }
        return data
    }

    func getTypeData(typeUrl: URL) async -> TypeData? {
        let jsonDecoder = JSONDecoder()
        guard let (response, _) = try? await URLSession.shared.data(from: typeUrl) else {
            return nil
        }
        guard let data = try? jsonDecoder.decode(TypeData.self, from: response) else {
            return nil
        }
        return data
    }

    func typeEffectiveness(attacker: TypeData, defender: [String]) -> Effectiveness? {
        var effectiveness: Effectiveness = .neutral
        for defendingType in defender {
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

    enum Effectiveness {
        case neutral
        case weak
        case resist
        case doubleWeak
        case doubleResist
        case immune

        func addWeak() -> Self {
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
            return .immune
        }

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
