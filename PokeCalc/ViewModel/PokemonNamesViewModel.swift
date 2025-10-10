//
//  PokemonNamesViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

@Observable
class PokemonNamesViewModel {
    var filteredResults: [PokemonBriefData] {
        return queryString == "" ? allPokemon : self.filter(allPokemon, on: queryString)
    }

    var queryString: String = ""
    private var allPokemon: [PokemonBriefData] = []

    private let fetcher = PokemonNamesFetcher()

    func loadNames() async {
        guard let namesData = await self.fetcher.fetch(()) else {
            return
        }
        let numbers = self.fetcher.numberList(species: namesData.speciesCount, total: namesData.names.count)
        await MainActor.run {
            self.allPokemon = zip(numbers, namesData.names).map { id, name in
                PokemonBriefData(apiID: id, name: name)
            }
        }
    }

    private func filter(_ data: [PokemonBriefData], on query: String) -> [PokemonBriefData] {
        return data.filter { pokemon in
            pokemon.name.lowercased().contains(query.lowercased())
        }
    }
}

struct PokemonBriefData: Hashable {
    let apiID: Int
    let name: String
}
