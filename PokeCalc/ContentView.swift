//
//  ContentView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin, Duong Anh Tran, Isabella Watt on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var database: DatabaseViewModel

    @State var alertPokemon = false
    @State var alertTeam = false
    @State var showingSheet = false

    @State var c = 1

    var body: some View {
        NavigationStack {
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
                // Testing section for update/delete
                Button {
                    alertTeam = !database.updateTeam(Team(id: 1, name: "New!!", isFavourite: true, pokemonIDs: [1, 2]))
                    alertPokemon = !database.updatePokemon(Pokemon(id: 1, pokemonNumber: 999, item: "N/A", level: 99, ability: "Sheer Force", effortValues: PokemonStats(hp: 1, attack: 1, defense: 1, specialAttack: 1, specialDefense: 1, speed: 1), nature: "Hardy", moves: ["Perish Song"]))
                } label: {
                    Text("Update 1")
                }
                Button {
                    alertTeam = !database.deleteTeam(by: 1)
                    alertPokemon = !database.deletePokemon(by: 1)
                } label: {
                    Text("Delete 1")
                }
                // Testing end
                Button {
                    let _ = database.clear()
                } label: {
                    Text("Clear")
                }
                
                // This is a testing button for the team list view:
                NavigationLink {
                    TeamsView()
                        .environmentObject(database)
                } label: {
                    Text("Test Team List View")
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
                PokemonLookupView()
                    .environmentObject(database)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseViewModel())
}
