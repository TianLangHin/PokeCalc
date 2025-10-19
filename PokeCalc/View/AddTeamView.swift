//
//  AddTeamView.swift
//  PokeCalc
//
//  Created by Bella on 13/10/2025.
//

import SwiftUI

struct AddTeamView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @Environment(\.dismiss) private var dismiss

    @State var teamName = ""
    @State var errorText = ""
    @State var createError = false

    var body: some View {
        VStack {
            Text("Add New Team")
                .font(.title3)
                .bold()

            TextField("Enter Team Name...", text: $teamName)
                .padding()

            Text(errorText)
                .opacity(createError ? 1 : 0)
                .foregroundStyle(Color.red)

            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

                Button {
                    addTeam()
                    if !createError {
                        dismiss()
                    }
                } label: {
                    Text("Submit")
                }
            }
        }
        .padding()
    }
    
    func addTeam() {
        // Obtain a unique team identifier and set this as the team ID.
        // If a team name is not specified, then the team name corresponds to its ID.
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
