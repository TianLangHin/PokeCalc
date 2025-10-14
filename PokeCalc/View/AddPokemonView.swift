//
//  AddPokemonView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

struct AddPokemonView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var team: Team?
    
    @State var item = ""
    @State var level = 1
    @State var ability = ""
    @State var nature = ""
    @State var moves = ""

    @State var addToTeamAlert: Bool = false
    @State var addPokemonAlert: Bool = false

    var body: some View {
        VStack {
            Text("\(pokemonNumber): \(pokemonName)")
            TextField("Item", text: $item)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Level", value: $level, format: .number)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Ability", text: $ability)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Nature", text: $nature)
                .textFieldStyle(.roundedBorder)
                .padding()
            TextField("Moves", text: $moves)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
            Button {
                let pokemon = Pokemon(
                    id: Pokemon.getUniqueId(),
                    pokemonNumber: pokemonNumber,
                    item: item,
                    level: level,
                    ability: ability,
                    effortValues: PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0),
                    nature: nature,
                    moves: Array(moves.split(separator: ",").map { String($0) }))
                
                if var team = team {
                    team.addPokemon(id: pokemon.id)
                    addToTeamAlert = !database.updateTeam(team)
                }
                addPokemonAlert = !database.addPokemon(pokemon)
                dismiss()
            } label: {
                Text("Add Pokémon")
            }
        }
        .alert("Add Pokémon Failed", isPresented: $addPokemonAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Add Pokémon to Team Failed", isPresented: $addToTeamAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
