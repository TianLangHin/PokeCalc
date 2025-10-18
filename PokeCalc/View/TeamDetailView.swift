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
    @State var pokeName = PokemonNamesViewModel()

    let team: Team

    var teamPoke: [Pokemon] {
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
            List {
                ForEach(teamPoke, id: \.self) { pokemon in
                    NavigationLink {
                        PokemonEditView(pokemon: pokemon, pokemonSpecies: (pokeName.getName(apiId: pokemon.pokemonNumber)).readableFormat())
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
                                Text("Species: \((pokeName.getName(apiId: pokemon.pokemonNumber)).readableFormat())")
                                Text("Pokemon Number: \(pokemon.pokemonNumber)")
                            }
                        }
                    }
                }
                .onDelete(perform: deletePokemon)
            }
            .onAppear {
                Task {
                    database.refresh()
                    await pokeName.loadNames()
                }
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
    }

    func toggleFavourite() {
        if let index = database.teams.firstIndex(where: {$0.id == team.id}) {
            database.teams[index].toggleFavourite()
            database.updateTeam(database.teams[index])
        }
    }

    func deletePokemon(at offsets: IndexSet) {
        var newPokemonIDs = team.pokemonIDs
        newPokemonIDs.remove(atOffsets: offsets)
        let newTeam = Team(
            id: team.id, name: team.name,
            isFavourite: team.isFavourite, pokemonIDs: newPokemonIDs)
        database.updateTeam(newTeam)
        for id in team.pokemonIDs {
            if !newPokemonIDs.contains(id) {
                database.deletePokemon(by: id)
            }
        }
    }
}




//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
