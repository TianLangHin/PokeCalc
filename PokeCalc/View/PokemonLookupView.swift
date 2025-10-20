//
//  PokemonLookupView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

struct PokemonLookupView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @Environment(\.dismiss) var dismiss

    @State var isDismiss: Bool = false
    @State var namesLookup = PokemonNamesViewModel()
    @State var team: Team?
    @State var isLoaded = false

    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            VStack {
                if isLoaded {
                    if team == nil {
                        Button {
                            selectedTab = 1
                        } label: {
                            Text("Click here to add new Pokémon sets instead!")
                        }
                    }

                    List {
                        ForEach(namesLookup.filteredResults, id: \.self) { pokemonData in
                            if let team = self.team {
                                let destView = AddPokemonView(
                                    dismissParent: $isDismiss,
                                    pokemonNumber: pokemonData.apiID,
                                    pokemonName: pokemonData.name,
                                    team: team)
                                    .environmentObject(database)

                                NavigationLink(destination: destView) {
                                    HStack {
                                        PokemonImageView(pokemonNumber: pokemonData.apiID)
                                        Text(pokemonData.name.readableFormat())
                                    }
                                }
                            } else {
                                let destView = PokemonSetupView(
                                    pokemonNumber: pokemonData.apiID,
                                    pokemonName: pokemonData.name)
                                    .environmentObject(database)

                                NavigationLink(destination: destView) {
                                    HStack {
                                        PokemonImageView(pokemonNumber: pokemonData.apiID)
                                        Text(pokemonData.name.readableFormat())
                                    }
                                }
                            }
                        }
                    }
                    .searchable(
                        text: $namesLookup.queryString,
                        prompt: team == nil ? "Look for an existing Pokémon setup..." : "Look for a Pokémon...")
                } else {
                    ProgressView()
                }
            }
            .task {
                isLoaded = false
                await namesLookup.loadNames()
                isLoaded = true
            }
            .onChange(of: isDismiss) { oldValue, newValue in
                if newValue {
                    dismissSelf()
                }
            }
        }
    }

    func dismissSelf() {
        isDismiss = false
        dismiss()
    }
}
