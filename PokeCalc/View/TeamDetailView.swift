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

    var body: some View {
        NavigationStack {
            Text(team?.name ?? "Placeholder")
                .font(.largeTitle)
                .bold()
            
            List {
                ForEach(teamPoke, id:\.id) { pokemon in
                    HStack {
                        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.pokemonNumber).png"
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        VStack {
                            Text("Species: \((pokeName.getName(apiId: pokemon.pokemonNumber)).stringConverter())")
                            Text("Pokemon Number: \(pokemon.pokemonNumber)")
                        }
                    }
                }
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
                        .foregroundColor(team?.isFavourite ?? false ? .red : .gray)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PokemonLookupView(team: team)
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
}

// I am putting this here for now
extension String {
    func stringConverter() -> String {
        self
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}



//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
