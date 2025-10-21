//
//  AddPokemonView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

/// This page allows the user to customise data regarding a new Pokemon they intend to add to a team.
struct AddPokemonView: View {
    // This view will programmatically dismiss itself,
    // and needs access to the database to access Pokemon information.
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    // As part of a navigation sequence, it will also toggle a value
    // of whether the parent (preceding) view needs to dismiss itself as well.
    @Binding var dismissParent: Bool

    // Upon startup, the View needs to know the API number of the Pokemon being added,
    // its name (so that it does not have to be looked up again), and the Team it should belong to.
    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var team: Team

    // These internal state variables are all the user-customisable data that the Pokemon will take on.
    @State var data: BattleDataFetcher.BattleData? = nil
    @State var item = ""
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
    @State var pokemonType: [String] = []

    let statNames: [String] = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]

    // Additionally, this View may make an alert if a database operation fails.
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
                                PokemonImageView(pokemonNumber: pokemonNumber)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 2)
                                            .fill(Color.white)
                                    )
                                    .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)
                                    .padding()
                                HStack {
                                    typeDisplay(pos: 0, types: pokemonType)
                                    typeDisplay(pos: 1, types: pokemonType)
                                }
                            }
                            VStack {
                                Spacer()
                                Text(pokemonName.readableFormat())
                                    .font(.title2)
                                    .bold()
                                Spacer()
                            }
                        }

                        // The user can then choose the Pokemon's item.
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
 
                        Spacer()
 
                    }
                    .padding(.top, 30)
                }

                Divider()

                // Meanwhile, the button for adding the Pokemon should always be accessible to the user,
                // just in case the user will want to customise very few things before adding immediately.
                Button {
                    // This carries out the database operation of adding the new Pokemon to the Team before dismissing.
                    savePokemon()
                    dismiss()
                    // To prevent timing clashes with the UI, the parent view is programmatically dismissed after a delay.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismissParent = true
                    }
                } label: {
                    Text("Add Pokémon")
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
            // The combat-related data is loaded upon startup, since it is asynchronous.
            await loadBattleData()
        }
        .alert("Could not add Pokémon to the team. Please try again later.", isPresented: $isAlerting) {
            // This alert appears if a database error occurs.
            Button("OK", role: .cancel) {}
        }
    }

    /// A sub-view for the display of a Pokemon's type, to allow faster compilation and better encapsulation.
    @ViewBuilder
    func typeDisplay(pos: Int, types: [String]) -> some View {
        let type = getType(pos: pos, types: types)
        if type != nil {
            let bgColour = Color.getBackgroundColour(type: type ?? "")
            let fgColour = Color.getForegroundColour(type: type ?? "")
            // The padding here is flexible depending on whether this is a single-typed or dual-typed Pokemon.
            Text(getType(pos: pos, types: types)?.capitalized ?? "unknown")
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
        let fetcher = BattleDataFetcher()
        self.data = await fetcher.fetch(self.pokemonNumber)
        if let data = self.data {
            // All Pokemon have at the very least one ability, so forcefully unwrapping like this will not cause any problems.
            if ability == "" {
                self.ability = data.abilities.first!
            }
            self.moveList = data.moves.map { $0.0 }.sorted()
            self.pokemonType = data.types.map { $0.0 }
            
            self.abilityList = data.abilities
        }
    }

    /// This function carries out the functionality of saving the new Pokemon into the database,
    /// as well as adding it to the Team.
    func savePokemon() {
        // The `stats` State variable contains the values which must be put into a `PokemonStats` instance.
        let evs = PokemonStats(
            hp: stats[0], attack: stats[1], defense: stats[2],
            specialAttack: stats[3], specialDefense: stats[4], speed: stats[5])
        // The new `Pokemon` instance is created.
        let pokemon = Pokemon(
            id: Pokemon.getUniqueId(),
            pokemonNumber: pokemonNumber,
            item: item,
            level: level,
            ability: ability,
            effortValues: evs,
            nature: nature,
            moves: [move1, move2, move3, move4].filter({ !$0.isEmpty && $0 != "None"}))
        // The current `Team` instance is modified so that the new value can be made.
        team.addPokemon(id: pokemon.id)
        // Then, the database operations are carried out: first by updating the Team then by adding the Pokemon.
        // If any operation is unsuccessful, the user is alerted.
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
}
