//
//  ShareExtensionView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI
import WidgetKit

/// This is the View that is shown when the user clicks the "Share..." option and selects this app.
struct ShareExtensionView: View {
    // The text highlighted is passed here automatically.
    @State var text: String

    // Placeholder for the team name that can be customised.
    @State var teamText = "Untitled"
    // The TeamReaderViewModel is used to convert the copied text into a Team struct.
    @State var teamReader = TeamReaderViewModel()
    // These are also needed to convert and save the information into the app.
    @State var nameLookup = PokemonNamesViewModel()
    @ObservedObject var database = DatabaseViewModel()

    // Sometimes, import errors may occur at this stage.
    // The user is notified of this with a custom alert (`alertText`)
    // which will appear depending on the change of the flag `isAlerting`.
    // This alert may also indicate success.
    @State var alertText = ""
    @State var isAlerting = false

    // Additionally, some alerts should not immediately dismiss the View.
    // This is governed by the `isClosing` flag.
    @State var isClosing = true

    init(text: String) {
        self.text = text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Here, the title of the share extension and the textbox for the team title appears.
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

                // This is the large text box where the copied text gets automatically populated.
                TextField("Your New Pokémon Team", text: $text, axis: .vertical)
                    .lineLimit(10...20)
                    .textFieldStyle(.roundedBorder)

                // The button to save the team is wide and at the bottom.
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
                // The required data that matches Pokemon names to API indices is loaded upon startup.
                await nameLookup.loadNames()
            }
            .alert(alertText, isPresented: $isAlerting) {
                // When an alert is dismissed, it signifies completion which means the widget should be refreshed.
                Button("OK", role: .cancel) {
                    WidgetCenter.shared.reloadAllTimelines()
                    if isClosing {
                        self.close()
                    }
                }
            }
        }
    }

    // The main function used to attempt to save the Pokemon team.
    func saveTeam() {
        // By default, in most cases, this button will show an alert and close the View once it is dismissed.
        isAlerting = true
        isClosing = true

        // First, the team is processed by the `TeamReaderViewModel`.
        let team = teamReader.readTeam(text)
        let teamName = teamText.trimmingCharacters(in: .whitespaces)

        // In these situations, the View should not be dismissed once the alert disappears,
        // since the user can change the team name.
        if database.teams.contains(where: { $0.name == teamName }) {
            alertText = "Team \(teamName) already exists."
            isClosing = false
            return
        } else if teamName == "" {
            alertText = "Please enter a valid team name!"
            isClosing = false
            return
        }

        // Next, each Pokemon is constructed.
        var pokemonList: [Pokemon] = []
        for pokemonEntry in team {
            let newID = Pokemon.getUniqueId()
            if let pokemon = teamReader.newValidPokemon(from: pokemonEntry, nameData: nameLookup.filteredResults, id: newID) {
                pokemonList.append(pokemon)
            } else {
                // If one of the conversions fail, notify the user.
                alertText = "Pokémon entry \(pokemonEntry.species) could not be loaded. Please check for invalid values."
                return
            }
        }

        // Finally, the team and Pokemon are constructed and entered into the database.
        let newTeam = Team(id: Team.getUniqueId(), name: teamName, isFavourite: false, pokemonIDs: pokemonList.map { $0.id })
        for pokemon in pokemonList {
            // First, each Pokemon is entered into the database.
            let success = database.addPokemon(pokemon)
            if !success {
                // If one of these fails, the user is notified.
                alertText = "Could not add Pokémon to the database. Please try again later."
                return
            }
        }
        // Finally, the Team is entered into the database.
        let success = database.addTeam(newTeam)
        // If this fails, the user is given an error message. Otherwise, a success message is given.
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
