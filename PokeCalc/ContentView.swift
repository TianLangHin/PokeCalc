//
//  ContentView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin, Duong Anh Tran, Isabella Watt on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var database = DatabaseViewModel()

    @State var alertPokemon = false
    @State var alertTeam = false
    @State var showingSheet = false

    @State var c = 1

    var body: some View {
        VStack {
            Text("Successful Initialisation: \(database.dbController.success)")
            HStack {
                Text("Pokemon")
                Button {
                    showingSheet = true
                } label: {
                    Text("Add")
                }
            }
            List {
                ForEach(database.pokemon, id: \.self) { pokemon in
                    Text("\(pokemon)")
                }
            }
            HStack {
                Text("Teams")
                Button {
                    let team = Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [c, c+1, c+2])
                    c += 1
                    alertTeam = !database.addTeam(team)
                } label: {
                    Text("Add Team")
                }
            }
            List {
                ForEach(database.teams, id: \.self) { team in
                    Text("\(team)")
                }
            }
            Button {
                let _ = database.clear()
            } label: {
                Text("Clear")
            }
        }
        .padding()
        .alert("Pokemon Fail", isPresented: $alertPokemon) {
            Button("Dismiss", role: .cancel) {}
        }
        .alert("Team Fail", isPresented: $alertTeam) {
            Button("Dismiss", role: .cancel) {}
        }
        .sheet(isPresented: $showingSheet) {
            AddPokemonView()
                .environmentObject(database)
        }
    }
}

#Preview {
    ContentView()
}
