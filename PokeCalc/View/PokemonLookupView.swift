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
    
    @State var isViewing: Bool

    var body: some View {
        NavigationStack {
            VStack {
                if isLoaded {
                    TextField((isViewing ? "Look for an existing Pokémon setup..." : "Look for a Pokémon..."), text: $namesLookup.queryString)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                    
                    if isViewing {
                        Button(action: {
                            selectedTab = 1
                        }) {
                            Text("Add a Pokemon to a Team NOW!")
                        }
                    }
                    
                    List {
                        ForEach(namesLookup.filteredResults, id: \.self) { pokemonData in
                            if isViewing {
                                NavigationLink(destination:
                                    PokemonSetupView(pokemonNumber: pokemonData.apiID, pokemonName: pokemonData.name)
                                        .environmentObject(database)) {
                                            HStack {
                                                PokemonImageView(pokemonNumber: pokemonData.apiID)
                                                Text(pokemonData.name.readableFormat())
                                            }
                                }
                            } else {
                                NavigationLink(destination: AddPokemonView(isDismiss: $isDismiss, pokemonNumber: pokemonData.apiID, pokemonName: pokemonData.name, team: team)
                                    .environmentObject(database)) {
                                        HStack {
                                            PokemonImageView(pokemonNumber: pokemonData.apiID)
                                            Text(pokemonData.name.readableFormat())
                                        }
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
