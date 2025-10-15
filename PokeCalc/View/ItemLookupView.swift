//
//  ItemLookupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//


import SwiftUI

struct ItemLookupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    @State var itemLookup = ItemsViewModel()
    @State var pokeID: Int
    @State var isLoaded = false
    
    var pokemon: Pokemon? {
        database.pokemon.first(where: { $0.id == pokeID })
    }
    

    var body: some View {
        VStack {
            if isLoaded {
                TextField("Look for a Item...", text: $itemLookup.queryString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                List {
                    ForEach(itemLookup.filteredResults, id: \.self) { itemData in
                        Button(action: {
                            if var pokemon = self.pokemon {
                                pokemon.item = itemData
                                if database.updatePokemon(pokemon) {
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(itemData).png"
                                AsyncImage(url: URL(string: url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                    case .failure:
                                        Image("0")
                                    @unknown default:
                                        Image("0")
                                    }
                                }
                                Text(itemData.readableFormat())
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            isLoaded = false
            await itemLookup.loadItems()
            isLoaded = true
        }
    }
}

