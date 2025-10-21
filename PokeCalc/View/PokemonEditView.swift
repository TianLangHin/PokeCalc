//
//  PokemonEditView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import SwiftUI

/// This page allows the user to customise data regarding an existing Pokemon in the team that they intend to edit.
struct PokemonEditView: View {
    // This view will programmatically dismiss itself,
    // and needs access to the database to access Pokemon information.
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    // This flag ensures that the view knows when not to overwrite selections of moves
    // when navigating backwards from a Picker in a NavigationList style.
    @State var isInitialised = false

    // This View also needs to be provided the `Pokemon` instance to be updated and the name of the Pokemon.
    let pokemon: Pokemon
    let pokemonSpecies: String

    // These internal state variables are all the user-customisable data that the Pokemon will take on.
    @State var data: BattleDataFetcher.BattleData? = nil
    @State var item = "None"
    @State var level = 100
    @State var ability = ""
    @State var nature = "Serious"
    @State var move1 = "None"
    @State var move2 = "None"
    @State var move3 = "None"
    @State var move4 = "None"

    @State var stats: [Int] = Array(repeating: 0, count: 6)
    @State var abilityList: [String] = []
    @State var moveList: [String] = []
    @State var pokemonTypes: [String] = []

    let statNames: [String] = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]

    // This view may also show an error alert if a database operation fails.
    @State var isAlerting: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // The main customisation interface does not fit on the screen entirely, so it is scrollable.
                ScrollView {
                    VStack {
                        // At the top, the Pokemon's image is displayed with its typing below it
                        // and next to its name.
                        HStack(spacing: 20) {
                            VStack {
                                PokemonImageView(pokemonNumber: pokemon.pokemonNumber)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 2)
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)
                                    .padding()
                                HStack {
                                    typeDisplay(pos: 0, types: pokemonTypes)
                                    typeDisplay(pos: 1, types: pokemonTypes)
                                }
                            }
                            VStack {
                                Spacer()
                                Text(pokemonSpecies.readableFormat())
                                    .font(.title2)
                                    .bold()
                                Spacer()
                            }
                        }
 
                        // The user can then choose the Pokemon's item.
                        // It also displays the currently selected item.
                        NavigationLink {
                            ItemLookupView(selectedItem: $item)
                        } label: {
                            HStack(spacing: 10) {
                                ItemImageView(item: item)
                                Text("Item: \(item == "" ? "Select an Item" : item.readableFormat())")
                            }
                        }
                        .padding()
 
                        // The user can also customise the Pokemon level.
                        VStack {
                            Text("Level")
                                .font(.title3)
                                .bold()
                            TextField("Enter the Pokemon Level", value: $level, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .padding(.bottom)
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
 
                        // Next come the more structured customisation options.
                        // The ability and nature are chosen from a Picker that is wrapped by a custom View.
                        VStack {
                            Text("Ability and Nature")
                                .font(.title3)
                                .bold()
                            PickerView(selection: $ability, listOfItems: data?.abilities ?? [], pickerTitle: "Ability:")
                            PickerView(selection: $nature, listOfItems: POKEMON_NATURES, pickerTitle: "Nature:")
                        }
                        .padding(.bottom, 20)
 
                        // The four-move moveset can also be customised using a custom View.
                        VStack {
                            Text("Move List")
                                .font(.title3)
                                .bold()
                            MoveChooserView(move: $move1, pokemonID: 0, moveList: moveList, currentMoveNum: 1)
                                .environmentObject(database)
                            MoveChooserView(move: $move2, pokemonID: 0, moveList: moveList, currentMoveNum: 2)
                                .environmentObject(database)
                            MoveChooserView(move: $move3, pokemonID: 0, moveList: moveList, currentMoveNum: 3)
                                .environmentObject(database)
                            MoveChooserView(move: $move4, pokemonID: 0, moveList: moveList, currentMoveNum: 4)
                                .environmentObject(database)
                        }
                        .padding()
 
                        // Finally, the effort values (consisting of six stat gauges) can be customised,
                        // each using a custom View.
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
 
                        // A warning (for domain-specific logic) will appear if a certain total threshold is exceeded.
                        Text("Total allocated EVs exceed 510, which is illegal in regular battle settings.")
                            .opacity(self.stats.reduce(0, +) <= 510 ? 0 : 1)
                            .foregroundStyle(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }

                Divider()

                // Meanwhile, the button for editing the Pokemon should always be accessible to the user,
                // just in case the user will want to customise very few things before adding immediately.
                Button {
                    updatePokemon()
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
            if !isInitialised {
                // Upon the appearance of the view, all the internal state is initialised
                // and the Pokemon-specific base data is loaded.
                await loadBattleData()
                move1 = pokemon.getMove(at: 0)
                move2 = pokemon.getMove(at: 1)
                move3 = pokemon.getMove(at: 2)
                move4 = pokemon.getMove(at: 3)
                item = pokemon.item
                level = pokemon.level
                ability = pokemon.ability
                nature = pokemon.nature
                isInitialised = true
            }
        }
        .alert("Could not modify the Pokémon. Please try again later.", isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    /// A sub-view for the display of a Pokemon's type, to allow faster compilation and better encapsulation.
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

    /// A convenience function to return the String name of the type at either position 0 (first type) or 1 (second type).
    /// Returns an optional to account for the possibility of a single-type Pokemon.
    func getType(pos: Int, types: [String]) -> String? {
        if types.count > pos {
            return types[pos]
        } else {
            return nil
        }
    }

    /// This function is called upon startup, fetching the combat-related data of the to-be-added Pokemon.
    /// It loads the relevant state variables with the fetched values.
    func loadBattleData() async {
        // The combat-related data is fetched.
        let battleDataFetcher = BattleDataFetcher()
        // The data is added to the state.
        self.data = await battleDataFetcher.fetch(pokemon.pokemonNumber)

        if let data = self.data {
            // If the API call was successful, the state of the View is also updated.
            self.moveList = data.moves.map { $0.0 }.sorted()
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

    /// This function carries out the functionality of saving the edited Pokemon into the database,
    /// causing the row of the original Pokemon to be updated.
    func updatePokemon() {
        // The `stats` State variable contains the values which must be put into a `PokemonStats` instance.
        let evs = PokemonStats(
            hp: stats[0], attack: stats[1], defense: stats[2],
            specialAttack: stats[3], specialDefense: stats[4], speed: stats[5])
        // The updated `Pokemon` instance is created.
        let newPokemon = Pokemon(
            id: pokemon.id,
            pokemonNumber: pokemon.pokemonNumber,
            item: item,
            level: level,
            ability: ability,
            effortValues: evs,
            nature: nature,
            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None" }))
        // The `updatePokemon` method is called from the database.
        let success = database.updatePokemon(newPokemon)
        if !success {
            isAlerting = true
        }
    }
}
