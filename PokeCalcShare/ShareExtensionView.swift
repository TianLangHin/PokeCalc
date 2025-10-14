//
//  ShareExtensionView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI
import WidgetKit

struct ShareExtensionView: View {
    @State var text: String
    @State var teamText = "Untitled"
    @State var teamReader = TeamReaderViewModel()
    @State var nameLookup = PokemonNamesViewModel()
    @ObservedObject var database = DatabaseViewModel()

    @State var alertText = ""
    @State var isAlerting = false

    init(text: String) {
        self.text = text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Team Name: ")
                        .font(.title2)
                        .padding()
                    TextField("Name...", text: $teamText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                TextField("Your New Pokémon Team", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                Button {
                    let team = teamReader.readTeam(text)
                    var pokemonList: [Pokemon] = []
                    for pokemonEntry in team {
                        let newID = Pokemon.getUniqueId()
                        if let pokemon = teamReader.newValidPokemon(from: pokemonEntry, nameData: nameLookup.filteredResults, id: newID) {
                            pokemonList.append(pokemon)
                        } else {
                            print(pokemonEntry.species)
                        }
                    }
                    let newTeam = Team(
                        id: Team.getUniqueId(), name: teamText,
                        isFavourite: false, pokemonIDs: pokemonList.map { $0.id })
                    for pokemon in pokemonList {
                        let success = database.addPokemon(pokemon)
                        if !success {
                            alertText = "Could not add Pokémon!"
                            isAlerting = true
                        }
                    }
                    let success = database.addTeam(newTeam)
                    if !success {
                        alertText = "Could not add team!"
                        isAlerting = true
                    } else {
                        alertText = "Team added!"
                        isAlerting = true
                    }
                } label: {
                    Text("Save Team!")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
            .navigationTitle("Import Pokémon Team")
            .toolbar {
                Button("Cancel") {
                    self.close()
                }
            }
            .task {
                await nameLookup.loadNames()
            }
            .alert(alertText, isPresented: $isAlerting) {
                Button("OK", role: .cancel) {
                    WidgetCenter.shared.reloadAllTimelines()
                    self.close()
                }
            }
        }
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
