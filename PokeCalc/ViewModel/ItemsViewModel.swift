//
//  ItemsViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 15/10/2025.
//

import SwiftUI

@Observable
class ItemsViewModel {
    var filteredResults: [String] {
        return queryString == "" ? allItems : self.filter(allItems, on: queryString)
    }

    var queryString: String = ""
    private var allItems: [String] = []

    func loadItems() async {
        let jsonDecoder = JSONDecoder()

        let endpoint = "https://pokeapi.co/api/v2/item"
        guard let url = URL(string: endpoint) else {
            return
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return
        }
        guard let data = try? jsonDecoder.decode(RawItemData.self, from: response) else {
            return
        }
        allItems = data.results.map { $0.name }
    }

    struct RawItemData: Codable {
        let results: [InnerItemData]

        struct InnerItemData: Codable {
            let name: String
        }
    }

    private func filter(_ data: [String], on query: String) -> [String] {
        return data.filter { item in
            item.lowercased().contains(query.lowercased())
        }
    }
}
