//
//  ItemsViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 15/10/2025.
//

import SwiftUI

/// This ViewModel manages both the loading of the data regarding all items available from PokéAPI,
/// as well as providing easy searching functionality when queried with a search string.
@Observable
class ItemsViewModel {
    // This computed property makes it easy to extract all items that satisfy a particular keyword query.
    var filteredResults: [String] {
        return queryString == "" ? allItems : self.filter(allItems, on: queryString)
    }
    // The keyword query is inputted via modifying this property.
    var queryString: String = ""

    // This array is initialised with the names of all items upon loading,
    // but is set to an empty one to start since the loading is asynchronous.
    private var allItems: [String] = []

    // A single API call to PokéAPI is required to load the names of all items available at once.
    func loadItems() async {
        let jsonDecoder = JSONDecoder()

        let endpoint = "https://pokeapi.co/api/v2/item"
        guard var requestUrl = URLComponents(string: endpoint) else {
            return
        }
        // By default, the limit is 20, but this is changed so that all items will be returned.
        requestUrl.queryItems = [URLQueryItem(name: "limit", value: "10000")]
        guard let url = requestUrl.url else {
            return
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return
        }
        guard let data = try? jsonDecoder.decode(RawItemData.self, from: response) else {
            return
        }
        // Finally, the inner String values of each element in the query's inner array is extracted
        // and the array of all items is populated with this array.
        allItems = data.results.map { $0.name }
    }

    // This custom struct aligns with the structure of the JSON returned from the API call.
    struct RawItemData: Codable {
        let results: [InnerItemData]

        struct InnerItemData: Codable {
            let name: String
        }
    }

    // This function returns all item names that match the user's query,
    // accounting for the difference between typical user input and API-specific naming conventions.
    private func filter(_ data: [String], on query: String) -> [String] {
        return data.filter { item in
            item.lowercased().contains(query.lowercased().replacingOccurrences(of: " ", with: "-"))
        }
    }
}
