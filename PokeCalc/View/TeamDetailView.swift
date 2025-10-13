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
    
    var body: some View {
        NavigationStack {
            Text(database.teams[id].name)
                .font(.largeTitle)
                .bold()
            
            List {
                ForEach(database.teams[id].pokemonIDs, id:\.self) { id in
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
                NavigationLink {
                    PokemonLookupView(team: database.teams[id])
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(database.teams[id].pokemonIDs.count >= Team.maxPokemon)
            }
        }
    }
}

//#Preview {
//    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
//        .environmentObject(DatabaseViewModel())
//}
