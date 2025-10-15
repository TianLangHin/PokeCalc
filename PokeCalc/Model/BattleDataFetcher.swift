//
//  BattleDataFetcher.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 15/10/2025.
//

import Foundation
/*
struct BattleDataFetcher: APIFetchable {
    typealias Parameters = Int
    typealias FetchedData = BattleData

    func fetch(_ pokemonNumber: Int) async -> BattleData? {
        let jsonDecoder = JSONDecoder()

        let endpoint = URL(string: "https://pokeapi.co/api/v2/pokemon")
        guard let url = endpoint else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        guard let data = try? jsonDecoder.decode(RawBattleData.self, from: response) else {
            return nil
        }
        return data.convert()
    }

    struct RawBattleData: Codable {
        let abilities: [AbilityData]
        let moves: [MoveData]
        let stats: [StatData]
        let types: [TypeData]
        let weight: Int

        func convert() -> BattleData {
            var baseStats = PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
            return BattleData(
                abilities: self.abilities.map { $0.name },
                moves: self.moves.map { $0.move },
                stats: baseStats,
                types: self.types,
                weight: self.weight)
        }

        struct AbilityData: Codable {
            let name: String
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
            let name: String
            let url: URL
        }
    }

    struct BattleData {
        let abilities: self.abilities.map { $0.name },
        let moves: self.moves.map { $0.move },
        let stats: baseStats,
        let types: TypeData
        let weight: Int
    }
}
*/
