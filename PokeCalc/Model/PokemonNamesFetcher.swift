//
//  PokemonNamesFetcher.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import Foundation

struct PokemonNamesFetcher: APIFetchable {
    typealias Parameters = ()
    typealias FetchedData = PokemonNamesData

    func numberList(species: Int, total: Int) -> [Int] {
        let demarcation = 10000
        return [Int](1...species) + [Int](demarcation + 1...demarcation + total - species)
    }

    func fetch(_: Parameters) async -> FetchedData? {
        let jsonDecoder = JSONDecoder()

        let pokemonNamesEndpoint = "https://pokeapi.co/api/v2/pokemon"
        guard var namesRequestUrl = URLComponents(string: pokemonNamesEndpoint) else {
            return nil
        }
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
        let names = namesData.results.map { $0.name }

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
        let count = countData.count

        return PokemonNamesData(speciesCount: count, names: names)
    }

    struct PokemonPaginationData: Codable {
        let results: [PokemonName]
    }

    struct PokemonName: Codable {
        let name: String
    }

    struct PokemonCountData: Codable {
        let count: Int
    }
}

struct PokemonNamesData {
    let speciesCount: Int
    let names: [String]
}
