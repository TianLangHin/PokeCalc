//
//  PokemonSetupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 17/10/2025.
//

import SwiftUI
import Foundation

/// This view is shown when the user taps on a Pokemon in the first page of the app.
/// It lists all the `Pokemon` instances that have been created and belong to the specified Pokemon species.
struct PokemonSetupView: View {
    // This view will sometimes need to dismiss itself, and also needs the database
    // to find all the made instances matching the species.
    @EnvironmentObject var database: DatabaseViewModel
    @Environment(\.dismiss) var dismiss

    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var isNotFilled: Bool = false

    var body: some View {
        List {
            ForEach(database.pokemon.filter { $0.pokemonNumber == pokemonNumber }, id: \.self) { pokemon in
                // This forced unwrapping works here since the app's workflow ensures a Pokemon set
                // must always exist within a team.
                let team = database.teams.filter { $0.pokemonIDs.contains(pokemon.id) }.first!
                NavigationLink {
                    // Tapping on a result allows the user to edit an existing set.
                    PokemonEditView(pokemon: pokemon, pokemonSpecies: pokemonName)
                        .environmentObject(database)
                        .presentationDragIndicator(.visible)
                } label: {
                    // The result shows both the image of the Pokemon as well as its name and team name.
                    HStack {
                        PokemonImageView(pokemonNumber: pokemonNumber)
                        VStack {
                            Text(pokemonName.readableFormat())
                            Text("Team: \(team.name)")
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .task {
            // Upon loading, the view will check if there is any Pokemon data matching the species.
            database.refresh()
            if database.pokemon.filter({ $0.pokemonNumber == pokemonNumber }).isEmpty {
                isNotFilled = true
            }
        }
        .alert("There is no existing set for this Pokémon, please chose another one!", isPresented: $isNotFilled) {
            // If there are no such entries for the Pokemon, the view is dismissed after an alert.
            Button("Close", role: .cancel) {
                dismiss()
            }
        }
    }
}
