//
//  ContentView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin, Duong Anh Tran, Isabella Watt on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var db = DatabaseViewModel()

    @State var alertPokemon = false
    @State var alertTeam = false

    @State var c = 1

    var body: some View {
        VStack {
            HStack {
                Text("Pokemon")
                Button {
                    let pokemon = Pokemon(
                        id: Pokemon.getUniqueId(),
                        pokemonNumber: 10194,
                        item: "Focus Sash",
                        level: 100,
                        effortValues: PokemonStats(
                            hp: 4, attack: 0, defense: 0,
                            specialAttack: 252, specialDefense: 0, speed: 252),
                        nature: "Timid",
                        moves: ["Astral Barrage", "Pollen Puff", "Protect", "Nasty Plot"])
                    alertPokemon = !db.addPokemon(pokemon)
                } label: {
                    Text("Add Calyrex")
                }
            }
            List {
                ForEach(db.pokemon, id: \.self) { pokemon in
                    Text("\(pokemon)")
                }
            }
            HStack {
                Text("Teams")
                Button {
                    let team = Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [c, c+1, c+2])
                    c += 1
                    alertTeam = !db.addTeam(team)
                } label: {
                    Text("Add Team")
                }
            }
            List {
                ForEach(db.teams, id: \.self) { team in
                    Text("\(team)")
                }
            }
            Button {
                let _ = db.clear()
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
    }
}

#Preview {
    ContentView()
}
