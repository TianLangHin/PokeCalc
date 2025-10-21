//
//  BattleDataFetcher.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 15/10/2025.
//

import Foundation

/// This resource fetches the combat-related data of a particular Pokémon
/// which is not explicitly stored within the database since it is uncustomisable.
/// Since the main function is fetching data from the external API, it conforms to `APIFetchable`.
struct BattleDataFetcher: APIFetchable {
    // Conforms to `APIFetchable` here.
    // The `Parameter` is an integer corresponding to the Pokémon's API index,
    // which can be determined from the data loaded by `PokemonNamesFetcher`.
    // The `FetchedData` contains the combat-related data that is necessary for damage calculation.
    typealias Parameters = Int
    typealias FetchedData = BattleData

    // Conforms to `APIFetchable` here.
    // This is the main function that retrieves the combat-related data of a particular Pokémon.
    func fetch(_ pokemonNumber: Int) async -> BattleData? {
        // The returned data is in a JSON format.
        let jsonDecoder = JSONDecoder()

        // The endpoint uses the number that is passed in to retrieve the correct Pokémon data.
        let endpoint = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonNumber)")
        guard let url = endpoint else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        // The structure of the returned JSON is in the form described by `RawBattleData`.
        guard let data = try? jsonDecoder.decode(RawBattleData.self, from: response) else {
            return nil
        }

        // The returned data is converted slightly from `RawBattleData` into the `BattleData` type,
        // to remove the unnecessary layers of nesting for easier usage in the rest of the program.
        return self.convert(data: data)
    }

    // Due to PokéAPI typically outputting more information that we need in this program,
    // their JSON structure uses a lot of nesting, which we need to parse correctly using
    // custom inner structs inside of `RawBattleData`.
    struct RawBattleData: Codable {
        let abilities: [AbilityData]
        let moves: [MoveData]
        let stats: [StatData]
        let types: [TypeData]

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

    // The layers of nesting present in the original returned JSON are not necessary for custom logic,
    // so a simpler structure is created that can still contain the same amount of information.
    struct BattleData {
        let abilities: [String]
        let moves: [(String, URL)]
        let stats: PokemonStats
        let types: [(String, URL)]
    }

    // This conversion function is used to convert from the returned JSON data from the API
    // into the simplier and more usable format to be used in other parts of the app.
    func convert(data: RawBattleData) -> BattleData {
        // The most significant piece of logic required in the conversion is
        // turning the array of stats (as returned by PokéAPI) into the custom `PokemonStats` struct for easier usage.
        var baseStats = PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
        let statNames = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
        for (index, name) in statNames.enumerated() {
            baseStats.addStat(name: name, value: data.stats[index].baseStat)
        }
        // After the `PokemonStats` conversion logic is done,
        // the other information is extracted as-is from the nested structs.
        return BattleData(
            abilities: data.abilities.map { $0.ability.name },
            moves: data.moves.map { ($0.move.name, $0.move.url) },
            stats: baseStats,
            types: data.types.map { ($0.type.name, $0.type.url) })
    }
}
