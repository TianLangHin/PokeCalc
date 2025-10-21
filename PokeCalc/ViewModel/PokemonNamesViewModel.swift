//
//  PokemonNamesViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

/// This ViewModel acts as a wrapper around the `PokemonNamesFetcher` struct to fetch the data
/// relating all the names of Pokemon with their corresponding numbers that the PokéAPI convention uses.
/// It also provides an easy way of searching for such Pokemon and their related data using a keyword search.
@Observable
class PokemonNamesViewModel {
    // The convenient searching functionality is achieved using this computed property,
    // where the search string is inputted by changing `queryString`.
    var filteredResults: [PokemonBriefData] {
        return queryString == "" ? allPokemon : self.filter(allPokemon, on: queryString)
    }
    // The search is conducted by modifying this property.
    var queryString: String = ""

    // This stores all the Pokemon data being fetched, and is initialised to an empty array
    // since the populating of values is done asynchronously after instantiation.
    private var allPokemon: [PokemonBriefData] = []

    // This resource is used to grab the data from the external API.
    private let fetcher = PokemonNamesFetcher()

    func loadNames() async {
        // If the API call fails, however, the list is not populated.
        guard let namesData = await self.fetcher.fetch(()) else {
            return
        }
        // The `PokemonNamesFetcher` resource is also used to create the list of entries
        // that correspond the Pokemon name with the API number.
        let numbers = self.fetcher.numberList(species: namesData.speciesCount, total: namesData.names.count)
        // `MainActor.run` is used here to ensure publishing updates are only done in the main thread.
        await MainActor.run {
            self.allPokemon = zip(numbers, namesData.names).map { id, name in
                PokemonBriefData(apiID: id, name: name)
            }
        }
    }

    // Conducts the filtering logic.
    private func filter(_ data: [PokemonBriefData], on query: String) -> [PokemonBriefData] {
        return data.filter { pokemon in
            pokemon.name.lowercased().contains(query.lowercased())
        }
    }

    // Convenience function for other users of this ViewModel,
    // since the database only stores the API ID and not the Pokemon name.
    func getName(apiId: Int) -> String {
        return allPokemon.first(where: { $0.apiID == apiId })?.name ?? "Unknown Pokemon"
    }
}

// This struct is widely used in the app, and hence it is defined outside the ViewModel for easier reference.
struct PokemonBriefData: Hashable {
    let apiID: Int
    let name: String
}
