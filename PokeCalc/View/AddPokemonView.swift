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

    @Binding var isDismiss: Bool
    
    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var team: Team?
    
    @State var data: BattleDataFetcher.BattleData?
    @State var item = ""
    @State var level = 1
    @State var ability = ""
    @State var nature = ""
    @State var moves = ""

    @State var addToTeamAlert: Bool = false
    @State var addPokemonAlert: Bool = false
    

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 125, height: 125)
                        case .failure:
                            Image("decamark")
                        @unknown default:
                            Image("decamark")
                        }
                    }
                    
                    VStack {
                        Text("**Current Pokemon**: \(pokemonName.readableFormat())")
                        Text("**Pokemon Number**: \(pokemonNumber)")
                    }
                }
        
                NavigationLink {
                    ItemLookupView(pokeID: 0, itemTF: $item)
                        .environmentObject(database)
                } label: {
                    HStack(spacing: 10) {
                        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(item).png"
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                            case .failure:
                                Image("decamark")
                            @unknown default:
                                Image("decamark")
                            }
                        }
                        Text("item: \(item == "" ? "None" : item.readableFormat())")
                    }
                }
                
                TextField("Level", value: $level, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                HStack {
                    Text("Ability: \(self.ability.readableFormat())")
                    
                    if let data = self.data {
                        Picker("Ability", selection: $ability) {
                            ForEach(data.abilities, id: \.self) { ability in
                                Text(ability.readableFormat())
                            }
                        }
                    }
                }
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
                    isDismiss = true
                    dismiss()
                } label: {
                    Text("Add Pokémon")
                }
            }
            .padding(.top, 30)
            .alert("Add Pokémon Failed", isPresented: $addPokemonAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Add Pokémon to Team Failed", isPresented: $addToTeamAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .task {
            await loadBattleData()
        }
    }
    
    func loadBattleData() async {
        let fetcher = BattleDataFetcher()
        self.data = await fetcher.fetch(self.pokemonNumber)
        if let data = self.data {
            // All Pokemon have at the very least one ability, so forcefully unwrapping like this will not cause any problems.
            self.ability = data.abilities.first!
        }
    }
}
