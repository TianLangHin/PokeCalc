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
    @State var pokeID: Int
    @EnvironmentObject var database: DatabaseViewModel
    @State var pokemonSpecies: String
    
    @State var isDismiss: Bool = false
    @State var initialised: Bool = false
    
    @State var data: BattleDataFetcher.BattleData?
    @State var item = "None"
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

    
    var pokemon: Pokemon? {
        database.pokemon.first(where: { $0.id == pokeID })
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack(spacing: 20) {
                        VStack {
                            PokemonImageView(pokemonNumber: pokemon?.pokemonNumber ?? 0)
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
                            Text("**\(pokemonSpecies.readableFormat())**")
                            Text("*Pokemon Number: \(String(pokemon?.pokemonNumber ?? 0))*")
                                .padding(.bottom, 35)
                            
                        }
                    }
                    
                    
                    
                    HStack {
                        ItemImageView(item: item)
                        
                        NavigationLink {
                            ItemLookupView(pokeID: pokeID, itemTF: $item)
                                .environmentObject(database)
                        } label: {
                            Text("item: \(item.readableFormat())")
                        }
                    }
                    
                    
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
                    
                    
                    
                    
                    
                    
                    // This is to work with preset team for now
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
                    
                    
                    
                    // Stepper for eV 252 for each, step 4
                    VStack {
                        Text("hp: \(pokemon?.effortValues.hp ?? 0)")
                        Text("atk: \(pokemon?.effortValues.attack ?? 0)")
                        Text("spatk: \(pokemon?.effortValues.specialAttack ?? 0)")
                        Text("spdef: \(pokemon?.effortValues.specialDefense ?? 0)")
                        Text("speed: \(pokemon?.effortValues.speed ?? 0)")
                        Text("def: \(pokemon?.effortValues.defense ?? 0)")
                    }
                    
                    
                    
                    
                    Button {
                        let newPokemon = Pokemon(
                            id: pokeID,
                            pokemonNumber: pokemon?.pokemonNumber ?? 0,
                            item: item,
                            level: level,
                            ability: ability,
                            effortValues: PokemonStats(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0),
                            nature: nature,
                            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None"}))
                        
                        let _ = database.updatePokemon(newPokemon)
                        isDismiss = true
                        dismiss()
                    } label: {
                        Text("Modify Pokémon")
                    }
                    .padding(.vertical, 20)
                    .frame(width: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .task {
                if !initialised {
                    await loadBattleData()
                    move1 = pokemon?.getMove(at: 0) ?? ""
                    move2 = pokemon?.getMove(at: 1) ?? ""
                    move3 = pokemon?.getMove(at: 2) ?? ""
                    move4 = pokemon?.getMove(at: 3) ?? ""
                    
                    item = item != "" ? item : pokemon?.item ?? "None"
                    level = pokemon?.level ?? 1
                    ability = pokemon?.ability ?? "No ability"
                    nature = pokemon?.nature ?? "No personality"
                    initialised = true
                }
            }
        }
    }
    
    
    
    
    
    func loadBattleData() async {
        let fetcher = BattleDataFetcher()
        self.data = await fetcher.fetch(pokemon?.pokemonNumber ?? 0)
        if let data = self.data {
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
