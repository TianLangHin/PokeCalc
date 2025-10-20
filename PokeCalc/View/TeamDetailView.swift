//
//  TeamDetailView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

struct TeamDetailView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @State var pokemonNames = PokemonNamesViewModel()

    @State var alertText = ""
    @State var isAlerting = false

    let team: Team

    var teamPokemon: [Pokemon] {
        team.pokemonIDs.compactMap { id in
            database.pokemon.first(where: { $0.id == id })
        }
    }

    @State var selectedPokemon = 0
    var body: some View {
        NavigationStack {
            Text(team.name)
                .font(.largeTitle)
                .bold()
            if teamPokemon.isEmpty {
                Spacer()
                Text("This team has no Pokémon. Start adding some with the + button!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(teamPokemon, id: \.self) { pokemon in
                        let species = pokemonNames.getName(apiId: pokemon.pokemonNumber).readableFormat()
                        NavigationLink {
                            PokemonEditView(pokemon: pokemon, pokemonSpecies: species)
                                .environmentObject(database)
                        } label: {
                            HStack {
                                let item = pokemon.item.apiGenericFormat()
                                VStack {
                                    Spacer()
                                    ItemImageView(item: item)
                                }
                                
                                PokemonImageView(pokemonNumber: pokemon.pokemonNumber)
                                VStack {
                                    Text("Species: \(species)")
                                    Text("Pokemon Number: \(pokemon.pokemonNumber)")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deletePokemon)
                }
            }
        }
        .onAppear {
            Task {
                database.refresh()
                await pokemonNames.loadNames()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    toggleFavourite()
                }) {
                    Image(systemName: team.isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
            
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
            Button("OK", role: .cancel) {}
        }
    }

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




//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
