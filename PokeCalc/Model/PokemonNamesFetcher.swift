//
//  PokemonNamesFetcher.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import Foundation

/// This resource fetches the names of all Pokémon from the external PokéAPI.
/// This allows the names of each Pokémon to be easily mapped to their index
/// as per the convention of the external API, which is useful for fetching data and sprites.
/// Since the main function is fetching data from the external API, it conforms to `APIFetchable`.
struct PokemonNamesFetcher: APIFetchable {
    // Conforms to `APIFetchable` here. No data needs to be passed in to a call
    // hence `Parameters` is the unit type, while the returned data is an integer
    // of how many species (not forms) there are as well as a list of all Pokemon forms.
    typealias Parameters = ()
    typealias FetchedData = PokemonNamesData

    // According to the API specification, default forms are indexed at their Pokedex number
    // but other forms are listed at integers above 10000.
    // This function creates the list of all possible indices when returned the total form count.
    func numberList(species: Int, total: Int) -> [Int] {
        let demarcation = 10000
        return [Int](1...species) + [Int](demarcation + 1...demarcation + total - species)
    }

    // Conforms to `APIFetchable` here.
    // The information regarding the number of form and species counts are retrieved here.
    func fetch(_: Parameters) async -> FetchedData? {
        // The fetched data is serialised in the form of a JSON object.
        let jsonDecoder = JSONDecoder()

        // In all of the below, in either request construction or in data parsing,
        // if an error occurs, it is turned into an optional and the function returns a `nil` early,
        // signalling that the operation had failed in a programmatic manner.

        // First, all the Pokemon names (all forms, which is more than the 1025 in the Pokdex) are retrieved.
        let pokemonNamesEndpoint = "https://pokeapi.co/api/v2/pokemon"
        guard var namesRequestUrl = URLComponents(string: pokemonNamesEndpoint) else {
            return nil
        }
        // The `limit` parameter is set to a high number to include all Pokemon, since the default only returns 20.
        namesRequestUrl.queryItems = [URLQueryItem(name: "limit", value: "10000")]
        guard let namesUrl = namesRequestUrl.url else {
            return nil
        }
        guard let (namesResponse, _) = try? await URLSession.shared.data(from: namesUrl) else {
            return nil
        }
        guard let namesData = try? jsonDecoder.decode(PokemonPaginationData.self, from: namesResponse) else {
            return nil
        }
        // After the JSON has been parsed, the inner String values are extracted into an array.
        let names = namesData.results.map { $0.name }

        // Second, the number of unique Pokemon species (currently 1025, but subject to change) is retrieved.
        let speciesCountEndpoint = "https://pokeapi.co/api/v2/pokemon-species"
        guard var countRequestUrl = URLComponents(string: speciesCountEndpoint) else {
            return nil
        }
        countRequestUrl.queryItems = [URLQueryItem(name: "limit", value: "10000")]
        guard let countUrl = countRequestUrl.url else {
            return nil
        }
        guard let (countResponse, _) = try? await URLSession.shared.data(from: countUrl) else {
            return nil
        }
        guard let countData = try? jsonDecoder.decode(PokemonCountData.self, from: countResponse) else {
            return nil
        }
        // After the JSON has been parsed, the inner Int value is extracted.
        let count = countData.count

        // The two extracted values are returned.
        return PokemonNamesData(speciesCount: count, names: names)
    }

    // Both `PokemonPaginationData` and the inner `PokemonName` represent
    // the returned JSON structure of the `/pokemon` PokéAPI endpoint.
    struct PokemonPaginationData: Codable {
        let results: [PokemonName]
    }

    struct PokemonName: Codable {
        let name: String
    }

    // Both `PokemonCountData` represents the returned JSON structure of the `/pokemon-species` PokéAPI endpoint.
    // Only the `count` property is needed here, since this is used to create the index list.
    struct PokemonCountData: Codable {
        let count: Int
    }
}

struct PokemonNamesData {
    let speciesCount: Int
    let names: [String]
}
