//
//  PokemonEditView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import Foundation
import SwiftUI

struct PokemonEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel
    let battleDataFetcher = BattleDataFetcher()

    let pokemon: Pokemon
    let pokemonSpecies: String

    @State var isDismiss: Bool = false
    @State var initialised: Bool = false

    @State var data: BattleDataFetcher.BattleData?
    @State var item = "None"
    @State var level = 100
    @State var ability = ""
    @State var nature = "Serious"
    @State var move1 = "None"
    @State var move2 = "None"
    @State var move3 = "None"
    @State var move4 = "None"

    @State var abilityList: [String] = []

    @State var statNames: [String] = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
    @State var stats: [Int] = Array(repeating: 0, count: 6)

    @State var moveListName: [String] = []
    @State var pokemonTypes: [String] = []

    @State var isAlerting: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack {
                        HStack(spacing: 20) {
                            VStack {
                                PokemonImageView(pokemonNumber: pokemon.pokemonNumber)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 2)
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)
                                
                                HStack {
                                    typeDisplay(pos: 0, types: pokemonTypes)
                                    typeDisplay(pos: 1, types: pokemonTypes)
                                }
                            }
                            
                            VStack {
                                Text("\(pokemonSpecies.readableFormat())")
                                    .bold()
                                Text("Pokemon Number: \(String(pokemon.pokemonNumber))")
                                    .padding(.bottom, 35)
                                    .italic()
                            }
                        }
                        
                        HStack {
                            ItemImageView(item: item)
                            NavigationLink {
                                ItemLookupView(selectedItem: $item)
                                    .environmentObject(database)
                            } label: {
                                Text("item: \(item.readableFormat())")
                            }
                        }
                        
                        VStack {
                            Text("Level:")
                                .font(.title3)
                                .bold()
                            TextField("Enter the Pokemon Level", value: $level, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
                        
                        VStack {
                            Text("Ability and Nature")
                                .font(.title3)
                                .bold()
                            if let data = self.data {
                                PickerView(selection: $ability, listOfItems: data.abilities, pickerTitle: "Ability:")
                            }
                            PickerView(selection: $nature, listOfItems: POKEMON_NATURES, pickerTitle: "Nature:")
                        }
                        .padding(.bottom, 20)
                        
                        VStack {
                            Text("Move List:")
                                .font(.title3)
                                .bold()
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move1, currentMoveNum: 1)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move2, currentMoveNum: 2)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move3, currentMoveNum: 3)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move4, currentMoveNum: 4)
                                .environmentObject(database)
                        }
                        .padding()
                        
                        Text("Effort Values")
                            .font(.title3)
                            .bold()
                        Grid {
                            ForEach(self.stats.indices, id: \.self) { index in
                                GridRow {
                                    StatGaugeView(stat: self.statNames[index], value: self.$stats[index])
                                }
                            }
                        }
                        .padding()
                        
                        Text("Total allocated EVs exceed 510, which is illegal in regular battle settings.")
                            .opacity(self.stats.reduce(0, +) <= 510 ? 0 : 1)
                            .foregroundStyle(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                        
                    }
                }

                Divider()

                Button {
                    updatePokemon()
                    isDismiss = true
                    dismiss()
                } label: {
                    Text("Update Pokémon")
                }
                .frame(width: 150)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .task {
            if !initialised {
                await loadBattleData()
                move1 = pokemon.getMove(at: 0)
                move2 = pokemon.getMove(at: 1)
                move3 = pokemon.getMove(at: 2)
                move4 = pokemon.getMove(at: 3)
                item = pokemon.item
                level = pokemon.level
                ability = pokemon.ability
                nature = pokemon.nature
                initialised = true
            }
        }
        .alert("Could not modify the Pokémon. Please try again later.", isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    func typeDisplay(pos: Int, types: [String]) -> some View {
        if let type = getType(pos: pos, types: types) {
            let bgColour = Color.getBackgroundColour(type: type)
            let fgColour = Color.getForegroundColour(type: type)
            let typeText = type.capitalized

            Text(typeText)
                .padding(pos == 0 ? 5 : getType(pos: 1, types: types) == nil ? 0 : 5)
                .background(bgColour)
                .foregroundColor(fgColour)
                .cornerRadius(10)
        } else {
            EmptyView()
        }
    }

    func getType(pos: Int, types: [String]) -> String? {
        if types.count > pos {
            return types[pos]
        } else {
            return nil
        }
    }

    func loadBattleData() async {
        self.data = await battleDataFetcher.fetch(pokemon.pokemonNumber)
        if let data = self.data {
            self.moveListName = data.moves.map { $0.0 }.sorted()
            self.pokemonTypes = data.types.map { $0.0 }
            self.abilityList = data.abilities

            let baseStats = [
                pokemon.effortValues.hp,
                pokemon.effortValues.attack,
                pokemon.effortValues.defense,
                pokemon.effortValues.specialAttack,
                pokemon.effortValues.specialDefense,
                pokemon.effortValues.speed
            ]

            for (key, value) in baseStats.enumerated() {
                self.stats[key] = value
            }
        }
    }

    func updatePokemon() {
        let evs = PokemonStats(
            hp: stats[0], attack: stats[1], defense: stats[2],
            specialAttack: stats[3], specialDefense: stats[4], speed: stats[5])
        let newPokemon = Pokemon(
            id: pokemon.id,
            pokemonNumber: pokemon.pokemonNumber,
            item: item,
            level: level,
            ability: ability,
            effortValues: evs,
            nature: nature,
            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None" }))
        let success = database.updatePokemon(newPokemon)
        if !success {
            isAlerting = true
        }
    }
}
