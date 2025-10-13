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
    
    var team: Team? {
        database.teams.first(where: { $0.id == id })
    }

    var body: some View {
        NavigationStack {
            Text(team?.name ?? "Placeholder")
                .font(.largeTitle)
                .bold()
            
            List {
                ForEach(team?.pokemonIDs ?? [], id:\.self) { id in
                    Text("Pokemon Number: \(id)")
                }
            }
            .onAppear {
                Task {
                    database.refresh()
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

//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
