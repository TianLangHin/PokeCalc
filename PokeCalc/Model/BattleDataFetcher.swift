//
//  BattleDataFetcher.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 15/10/2025.
//

import Foundation

struct BattleDataFetcher: APIFetchable {
    typealias Parameters = Int
    typealias FetchedData = BattleData

    func fetch(_ pokemonNumber: Int) async -> BattleData? {
        let jsonDecoder = JSONDecoder()

        let endpoint = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonNumber)")
        guard let url = endpoint else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        guard let data = try? jsonDecoder.decode(RawBattleData.self, from: response) else {
            return nil
        }
        return self.convert(data: data)
    }

    struct RawBattleData: Codable {
        let abilities: [AbilityData]
        let moves: [MoveData]
        let stats: [StatData]
        let types: [TypeData]
        let weight: Int

        struct AbilityData: Codable {
            let ability: RawAbilityData

            struct RawAbilityData: Codable {
                let name: String
            }
        }

        struct MoveData: Codable {
            let move: RawMoveData

            struct RawMoveData: Codable {
                let name: String
                let url: URL
            }
        }

        struct StatData: Codable {
            let baseStat: Int

            enum CodingKeys: String, CodingKey {
                case baseStat = "base_stat"
            }
        }

        struct TypeData: Codable {
            let type: RawTypeData

            struct RawTypeData: Codable {
                let name: String
                let url: URL
            }
        }
    }

    struct BattleData {
        let abilities: [String]
        let moves: [(String, URL)]
        let stats: PokemonStats
        let types: [(String, URL)]
        let weight: Int
    }

    func convert(data: RawBattleData) -> BattleData {
        var baseStats = PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
        let statNames = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
        for (index, name) in statNames.enumerated() {
            baseStats.addStat(name: name, value: data.stats[index].baseStat)
        }
        return BattleData(
            abilities: data.abilities.map { $0.ability.name },
            moves: data.moves.map { ($0.move.name, $0.move.url) },
            stats: baseStats,
            types: data.types.map { ($0.type.name, $0.type.url) },
            weight: data.weight)
    }
}
