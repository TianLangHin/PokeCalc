//
//  AddTeamView.swift
//  PokeCalc
//
//  Created by Bella on 13/10/2025.
//

import SwiftUI

/// This View is a pop up that will allow the user to add a new Team.
struct AddTeamView: View {
    // This view may dismiss itself, and also needs access to the database to add the new Team.
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    // The user will enter a name that must be kept track of.
    @State var teamName = ""

    // Additionally, some errors may pop up which will manifest as an alert controlled by these state variables.
    @State var errorText = ""
    @State var createError = false

    var body: some View {
        VStack {
            Text("Add New Team")
                .font(.title3)
                .bold()

            TextField("Enter Team Name...", text: $teamName)
                .autocorrectionDisabled()
                .padding()

            Text(errorText)
                .opacity(createError ? 1 : 0)
                .foregroundStyle(Color.red)

            // The user has the option to either "cancel" (i.e., dismiss the view)
            // or to add the team which will also dismiss the view if an error doesn't occur.
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .padding()

                Button {
                    addTeam()
                    if !createError {
                        dismiss()
                    }
                } label: {
                    Text("Add Team!")
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    func addTeam() {
        // Obtain a unique team identifier and set this as the team ID.
        // If a team name is not specified, then the team name corresponds to its ID.
        createError = false
        let teamID = Team.getUniqueId()
        if teamName.isEmpty {
            teamName = "Team \(teamID)"
        }
        if database.teams.contains(where: { $0.name == teamName }) {
            errorText = "This team name already exists. Please enter another name."
            createError = true
        } else {
            let newTeam = Team(id: teamID, name: teamName, isFavourite: false, pokemonIDs: [])
            let success = database.addTeam(newTeam)
            if !success {
                errorText = "Could not add team to the database. Please try again later."
                createError = true
            }
        }
    }
}
