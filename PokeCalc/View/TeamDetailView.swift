//
//  TeamDetailView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

/// This view displays a particular `Team` instance, showing the list of all Pokemon in the team
/// and allowing customisation of each of these. Additionally, it allows adding to and deleting from
/// the team, as well as toggling its favourite status which will determine whether it is displayed in the widget.
struct TeamDetailView: View {
    // Since the Team will sometimes be edited here, the database needs to be given as an environment object.
    @EnvironmentObject var database: DatabaseViewModel

    // Since the Pokemon species names need to be displayed despite them not being stored,
    // the `PokemonNamesViewModel` instance needs to be created.
    @State var pokemonNames = PokemonNamesViewModel()

    // Sometimes, the database operations may fail. This will cause an alert to pop up, notifying the user.
    @State var alertText = ""
    @State var isAlerting = false

    // The team that is being displayed is provided as an argument.
    let team: Team

    // The list of Pokemon in the team needs to be retrieved from the database,
    // since the `Team` instance only contains their primary keys.
    var teamPokemon: [Pokemon] {
        team.pokemonIDs.compactMap { id in
            database.pokemon.first(where: { $0.id == id })
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // The team name is shown at the top.
                Text(team.name)
                    .font(.largeTitle)
                    .bold()
                if teamPokemon.isEmpty {
                    // If there are no Pokemon in the team, this is signified with a placeholder.
                    Spacer()
                    Text("This team has no Pokémon. Start adding some with the + button!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    // Otherwise, the Pokemon are listed out,
                    // each of which is a navigation link that allows the Pokemon set to be edited when tapped.
                    List {
                        ForEach(teamPokemon, id: \.self) { pokemon in
                            let species = pokemonNames.getName(apiId: pokemon.pokemonNumber).readableFormat()
                            NavigationLink {
                                PokemonEditView(pokemon: pokemon, pokemonSpecies: species)
                                    .environmentObject(database)
                            } label: {
                                // The display UI for each of these elements consists of
                                // its held item on the left lower corner, and then the Pokemon's sprite
                                // followed by its name.
                                HStack {
                                    let item = pokemon.item.apiGenericFormat()
                                    VStack {
                                        Spacer()
                                        ItemImageView(item: item)
                                    }
                                    PokemonImageView(pokemonNumber: pokemon.pokemonNumber)
                                    Text(species)
                                }
                            }
                        }
                        .onDelete(perform: deletePokemon)
                        // This list also has the native delete functionality.
                    }
                }
            }
        }
        .task {
            // Upon startup, the database is refreshed and the data for matching names with species is loaded.
            database.refresh()
            await pokemonNames.loadNames()
        }
        .toolbar {
            // In the toolbar, the button for toggling the team's favourite status
            // and adding Pokemon are provided with intuitive buttons.
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavourite()
                } label: {
                    Image(systemName: team.isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
            // The button for adding Pokemon is disabled if the maximum number of Pokemon is already in the team.
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PokemonLookupView(team: team, selectedTab: .constant(1))
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(team.pokemonIDs.count >= Team.maxPokemon)
                .foregroundColor(team.pokemonIDs.count >= Team.maxPokemon ? .gray : .accentColor)
            }
        }
        .alert(alertText, isPresented: $isAlerting) {
            // The alert appears with the customised error text here when needed.
            Button("OK", role: .cancel) {}
        }
    }

    // When the button to toggle favourite status is tapped,
    // the database needs to be updated immediately to reflect this change.
    // If it fails, the user should be notified instead.
    func toggleFavourite() {
        if let index = database.teams.firstIndex(where: {$0.id == team.id}) {
            database.teams[index].toggleFavourite()
            let success = database.updateTeam(database.teams[index])
            if !success {
                alertText = "Could not update team favourite status. Please try again later."
                isAlerting = true
            }
        }
    }

    // When a Pokemon is deleted from the Team, the database needs to be updated immediately.
    // If it fails, the user should be notified instead.
    // Additionally, the Pokemon instance is to be removed from the Pokemon table,
    // since no other Team instances could possibly refer to the same exact row.
    func deletePokemon(at offsets: IndexSet) {
        var newPokemonIDs = team.pokemonIDs
        newPokemonIDs.remove(atOffsets: offsets)
        let newTeam = Team(
            id: team.id, name: team.name,
            isFavourite: team.isFavourite, pokemonIDs: newPokemonIDs)
        let updateSuccess = database.updateTeam(newTeam)
        if !updateSuccess {
            alertText = "Could not update team with Pokémon removals. Please try again later."
            isAlerting = true
        } else {
            // The Pokemon is removed not just from the team but also from the Pokemon table here.
            for id in team.pokemonIDs {
                if !newPokemonIDs.contains(id) {
                    let success = database.deletePokemon(by: id)
                    if !success {
                        alertText = "Pokémon deletion unsuccessful. Please try again later."
                        isAlerting = true
                    }
                }
            }
        }
    }
}
