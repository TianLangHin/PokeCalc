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

    @Binding var dismissParent: Bool

    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var team: Team

    @State var data: BattleDataFetcher.BattleData?
    @State var item = ""
    @State var level = 100
    @State var ability = ""
    @State var nature = "Serious"
    @State var move1 = "None"
    @State var move2 = "None"
    @State var move3 = "None"
    @State var move4 = "None"

    @State var statNames: [String] = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
    @State var stats: [Int] = Array(repeating: 0, count: 6)

    @State var abilityList: [String] = []

    @State var moveListName: [String] = []
    @State var pokeType: [String] = []

    @State var isAlerting: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack(spacing: 20) {
                        VStack {
                            PokemonImageView(pokemonNumber: pokemonNumber)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                        .fill(Color.white)
                                )
                                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)

                            HStack {
                                typeDisplay(pos: 0, types: pokeType)
                                typeDisplay(pos: 1, types: pokeType)
                            }
                        }

                        VStack {
                            Text("**\(pokemonName.readableFormat())**")
                            Text("*Pokemon Number: \(pokemonNumber)*")
                                .padding(.bottom, 35)
                        }
                    }

                    NavigationLink {
                        ItemLookupView(selectedItem: $item)
                            .environmentObject(database)
                    } label: {
                        HStack(spacing: 10) {
                            ItemImageView(item: item)
                            Text("Item: \(item == "" ? "Select an Item" : item.readableFormat())")
                        }
                    }
                    .padding()

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
                        PickerView(selection: $ability, listOfItems: data?.abilities ?? [], pickerTitle: "Ability:")
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

                    Spacer()

                    Button {
                        savePokemon()
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismissParent = true
                        }
                    } label: {
                        Text("Add Pokémon")
                    }
                    .padding(.vertical, 20)
                    .frame(width: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
        
                }
                .padding(.top, 30)
                .alert("Could not add Pokémon to the team. Please try again later.", isPresented: $isAlerting) {
                    Button("OK", role: .cancel) {}
                }
            }
            .task {
                await loadBattleData()
            }
        }
    }
    
    func loadBattleData() async {
        let fetcher = BattleDataFetcher()
        self.data = await fetcher.fetch(self.pokemonNumber)
        if let data = self.data {
            // All Pokemon have at the very least one ability, so forcefully unwrapping like this will not cause any problems.
            if ability == "" {
                self.ability = data.abilities.first!
            }
            self.moveListName = data.moves.map{ $0.0 }.sorted()
            self.pokeType = data.types.map{ $0.0 }
            
            self.abilityList = data.abilities
        }
    }
    
    
    func typeText(pos: Int, empty: String, types: [String]) -> String {
        let type = getType(pos: pos, types: types)
        return type?.capitalized ?? empty
    }
    
    @ViewBuilder
    func typeDisplay(pos: Int, types: [String]) -> some View {
        let type = getType(pos: pos, types: types)
        if type != nil {
            let bgColour = Color.getBackgroundColour(type: type ?? "")
            let fgColour = Color.getForegroundColour(type: type ?? "")
            Text("\(typeText(pos: pos, empty: "unknown", types: types))")
                .padding(pos == 0 ? 5 : getType(pos: 1, types: types) == nil ? 0 : 5)
                .background(bgColour)
                .foregroundColor(fgColour)
                .cornerRadius(10)
        } else {
            EmptyView()
        }
    }

    func savePokemon() {
        let evs = PokemonStats(
            hp: stats[0], attack: stats[1], defense: stats[2],
            specialAttack: stats[3], specialDefense: stats[4], speed: stats[5])
        let pokemon = Pokemon(
            id: Pokemon.getUniqueId(),
            pokemonNumber: pokemonNumber,
            item: item,
            level: level,
            ability: ability,
            effortValues: evs,
            nature: nature,
            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None"}))
        team.addPokemon(id: pokemon.id)
        let updateTeamSuccess = database.updateTeam(team)
        if updateTeamSuccess {
            let addPokemonSuccess = database.addPokemon(pokemon)
            if !addPokemonSuccess {
                isAlerting = true
            }
        } else {
            isAlerting = true
        }
    }

    func getType(pos: Int, types: [String]) -> String? {
        if types.count > pos {
            return types[pos]
        } else {
            return nil
        }
    }
}
