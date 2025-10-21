//
//  PokemonLookupView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

/// This view serves one of the main functionalities of the app, and is on the first page of the app.
/// It allows the user to lookup existing sets they have made for any Pokémon.
/// This view is also reused in cases where a Pokémon is looked up specifically for immediate addition to a team.
struct PokemonLookupView: View {
    // This view needs access to the database environment variable to pass it to child views.
    @EnvironmentObject var database: DatabaseViewModel
    // It will also programmatically dismiss itself when triggered by a child view,
    // which is governed by a state which is passed as a binding.
    // The programmatic dismissal also needs the environment function.
    @Environment(\.dismiss) var dismiss
    @State var isDismiss: Bool = false

    // The `namesLookup` ViewModel here is used to govern the filtering logic for the list of all Pokemon
    // that the user can choose from.
    @State var namesLookup = PokemonNamesViewModel()
    // If this View is used purely from the app's main tab, no team is being made and thus this will be nil.
    // If not, (i.e., access from the second tab), then a team is provided to slightly modify its behaviour.
    @State var team: Team?

    // Since this view will need to load information asynchronously upon startup,
    // a flag is used to either display a ProgressView or the actual content.
    @State var isLoaded = false

    // This is here to automatically navigate to the next tab in case this is needed.
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            VStack {
                if isLoaded {
                    // It is possible that the user intended to make new Pokemon sets instead.
                    // In this case, a button is provided to prompt this user to move to the correct view.
                    if team == nil {
                        Button {
                            selectedTab = 1
                        } label: {
                            Text("Click here to add new Pokémon sets instead!")
                        }
                    }

                    // The list of all possible Pokemon (that match the search query) is shown here.
                    List {
                        ForEach(namesLookup.filteredResults, id: \.self) { pokemonData in
                            if let team = self.team {
                                // If there is a `Team` instance being passed to this view,
                                // then the list will bring the user to the view that adds a new Pokemon of this species.
                                let destView = AddPokemonView(
                                    dismissParent: $isDismiss,
                                    pokemonNumber: pokemonData.apiID,
                                    pokemonName: pokemonData.name,
                                    team: team)
                                    .environmentObject(database)

                                // The clickable navigation link will display the sprite and the name of the Pokemon.
                                NavigationLink(destination: destView) {
                                    HStack {
                                        PokemonImageView(pokemonNumber: pokemonData.apiID)
                                        Text(pokemonData.name.readableFormat())
                                    }
                                }
                            } else {
                                // If there is no `Team` instance being passed to this view,
                                // then the list will instead show the user all existing setups for this Pokemon.
                                let destView = PokemonSetupView(
                                    pokemonNumber: pokemonData.apiID,
                                    pokemonName: pokemonData.name)
                                    .environmentObject(database)

                                // The clickable navigation link will display the sprite and the name of the Pokemon.
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
                    // The list is also searchable using the native `searchable` modifier for a more consistent UI.
                } else {
                    // If the data has not been loaded yet, a progress spinner is shown to indicate this.
                    ProgressView()
                }
            }
            .task {
                isLoaded = false
                await namesLookup.loadNames()
                isLoaded = true
            }
            .onChange(of: isDismiss) { oldValue, newValue in
                // When the child view sets the `isDismiss` flag to true through the binding, this view dismisses.
                if newValue {
                    isDismiss = false
                    dismiss()
                }
            }
        }
    }
}
