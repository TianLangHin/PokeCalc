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
    @State var nature = "Serious"
    @State var move1 = "None"
    @State var move2 = "None"
    @State var move3 = "None"
    @State var move4 = "None"
    
    @State var abilityList: [String] = []
    
    @State var moveListName: [String] = []
    @State var pokeType: [String] = []

    @State var addToTeamAlert: Bool = false
    @State var addPokemonAlert: Bool = false
    

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
                        ItemLookupView(pokeID: 0, itemTF: $item)
                            .environmentObject(database)
                    } label: {
                        HStack(spacing: 10) {
                            ItemImageView(item: item)
                            Text("Item: \(item == "" ? "Select an Item" : item.readableFormat())")
                        }
                    }
                    .padding()
                    
                    VStack {
                        Text("**Level:**")
                            .font(.title3)
                        
                        TextField("Enter the Pokemon Level", value: $level, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .padding(.bottom)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                    
                    VStack {
                        Text("**Ability and Nature**")
                            .font(.title3)
                        
                        if let data = self.data {
                            PickerView(selection: $ability, listOfItems: data.abilities, pickerTitle: "Ability:")
                        }
                        
                        
                        PickerView(selection: $nature, listOfItems: POKEMON_NATURES, pickerTitle: "Nature:")
                    }
                    .padding(.bottom, 20)
                    
                    
                    VStack {
                        Text("**Move List:**")
                            .font(.title3)
                        
                        if self.data != nil {
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move1, currentMoveNum: 1)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move2, currentMoveNum: 2)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move3, currentMoveNum: 3)
                                .environmentObject(database)
                            MoveChooserView(pokeID: 0, moveListName: moveListName, move: $move4, currentMoveNum: 4)
                                .environmentObject(database)
                        }
                    }
                    .padding(.bottom, 30)
                    
                    
                    
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
                            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None"}))
                        
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
                    .padding(.vertical, 20)
                    .frame(width: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
        
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
            let bgColour = getBackgroundColour(type: type ?? "")
            let fgColour = getForegroundColour(type: type ?? "")

            Text("\(typeText(pos: pos, empty: "unknown", types: types))")
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

    
    func getBackgroundColour(type: String) -> Color {
        switch type {
        case "normal":
            return Color(hex: 0xA8A77A)
        case "fighting":
            return Color(hex: 0xC22E28)
        case "flying":
            return Color(hex: 0xA98FF3)
        case "poison":
            return Color(hex: 0xA33EA1)
        case "ground":
            return Color(hex: 0xE2BF65)
        case "rock":
            return Color(hex: 0xB6A136)
        case "bug":
            return Color(hex: 0xA6B91A)
        case "steel":
            return Color(hex: 0xB7B7CE)
        case "ghost":
            return Color(hex: 0x735797)
        case "fire":
            return Color(hex: 0xEE8130)
        case "water":
            return Color(hex: 0x6390F0)
        case "grass":
            return Color(hex: 0x7AC74C)
        case "electric":
            return Color(hex: 0xF7D02C)
        case "psychic":
            return Color(hex: 0xF95587)
        case "ice":
            return Color(hex: 0x96D9D6)
        case "dragon":
            return Color(hex: 0x6F35FC)
        case "dark":
            return Color(hex: 0x705746)
        case "fairy":
            return Color(hex: 0xD685AD)
        default:
            return Color.clear
        }
    }

    // Colours for the foreground text when put against the above background color,
    // designed to maximise contrast with the background colour.
    func getForegroundColour(type: String) -> Color {
        switch type {
        case "normal":
            return Color.white
        case "fighting":
            return Color.white
        case "flying":
            return Color.black
        case "poison":
            return Color.white
        case "ground":
            return Color.black
        case "rock":
            return Color.white
        case "bug":
            return Color.white
        case "steel":
            return Color.black
        case "ghost":
            return Color.white
        case "fire":
            return Color.black
        case "water":
            return Color.black
        case "grass":
            return Color.black
        case "electric":
            return Color.black
        case "psychic":
            return Color.white
        case "ice":
            return Color.black
        case "dragon":
            return Color.white
        case "dark":
            return Color.white
        case "fairy":
            return Color.black
        default:
            return Color.clear
        }
    }
}
