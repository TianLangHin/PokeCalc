//
//  TeamDetailView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

struct TeamDetailView: View {
    @State var id: Int
    @EnvironmentObject var database: DatabaseViewModel
    @State var pokeName = PokemonNamesViewModel()

    var team: Team? {
        database.teams.first(where: { $0.id == id })
    }

    var teamPoke: [Pokemon] {
        (team?.pokemonIDs ?? []).compactMap { id in
            database.pokemon.first(where: { $0.id == id })
        }
    }

    @State var selectedPokemon = 0
    var body: some View {
        NavigationStack {
            Text(team?.name ?? "Placeholder")
                .font(.largeTitle)
                .bold()
            NavigationLink {
                SwipeTeamView(team: team!, selectedPokemon: $selectedPokemon, size: CGFloat(300))
            } label: {
                Text("Swipe Team View, selected: \(selectedPokemon)")
            }
            List {
                ForEach(teamPoke, id: \.self) { pokemon in
                    NavigationLink {
                        PokemonEditView(pokeID: pokemon.id, pokemonSpecies: (pokeName.getName(apiId: pokemon.pokemonNumber)).readableFormat())
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
                    Image(systemName: team?.isFavourite ?? false ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PokemonLookupView(team: team, selectedTab: .constant(1), isViewing: false)
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(team?.pokemonIDs.count ?? 0 >= Team.maxPokemon)
                .foregroundColor(team?.pokemonIDs.count ?? 0 >= Team.maxPokemon ? .gray : .accentColor)
            }
        }
    }
    
    func toggleFavourite() {
        if let index = database.teams.firstIndex(where: {$0.id == id}) {
            database.teams[index].toggleFavourite()
            database.updateTeam(database.teams[index])
        }
    }

    func deletePokemon(at offsets: IndexSet) {
        if let validTeam = team {
            var newPokemonIDs = validTeam.pokemonIDs
            newPokemonIDs.remove(atOffsets: offsets)
            let newTeam = Team(
                id: validTeam.id, name: validTeam.name,
                isFavourite: validTeam.isFavourite, pokemonIDs: newPokemonIDs)
            database.updateTeam(newTeam)
            database.clearUnusedPokemon()
        }
    }
}




//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
