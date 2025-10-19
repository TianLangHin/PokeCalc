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
    @State var isClosing = true

    init(text: String) {
        self.text = text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Text("Team Name: ")
                        .font(.title2)
                        .bold()
                        .padding()
                    TextField("Name...", text: $teamText)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                TextField("Your New Pokémon Team", text: $text, axis: .vertical)
                    .lineLimit(10...20)
                    .textFieldStyle(.roundedBorder)
                Button {
                    saveTeam()
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
                    if isClosing {
                        self.close()
                    }
                }
            }
        }
    }

    func saveTeam() {
        isAlerting = true
        isClosing = true
        let team = teamReader.readTeam(text)
        let teamName = teamText.trimmingCharacters(in: .whitespaces)
        if database.teams.contains(where: { $0.name == teamName }) {
            alertText = "Team \(teamName) already exists."
            isClosing = false
            return
        } else if teamName == "" {
            alertText = "Please enter a valid team name!"
            isClosing = false
            return
        }
        var pokemonList: [Pokemon] = []
        for pokemonEntry in team {
            let newID = Pokemon.getUniqueId()
            if let pokemon = teamReader.newValidPokemon(from: pokemonEntry, nameData: nameLookup.filteredResults, id: newID) {
                pokemonList.append(pokemon)
            } else {
                alertText = "Pokémon entry \(pokemonEntry.species) could not be loaded. Please check for invalid values."
                return
            }
        }
        let newTeam = Team(id: Team.getUniqueId(), name: teamName, isFavourite: false, pokemonIDs: pokemonList.map { $0.id })
        for pokemon in pokemonList {
            let success = database.addPokemon(pokemon)
            if !success {
                alertText = "Could not add Pokémon to the database. Please try again later."
                return
            }
        }
        let success = database.addTeam(newTeam)
        if !success {
            alertText = "Could not add team to the database. Please try again later."
        } else {
            alertText = "Team added!"
        }
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
