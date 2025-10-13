//
//  AddTeamView.swift
//  PokeCalc
//
//  Created by Bella on 13/10/2025.
//

import SwiftUI

struct AddTeamView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @Binding var isPresented: Bool
    @State var teamName: String = ""
    @State var createError: Bool = false
    
    var body: some View {
        VStack {
            Text("Add New Team")
                .font(.title3)
                .bold()
            
            TextField("Enter Team Name...", text: $teamName)
                .padding()
            
            Text("Error creating team. Please try again.")
                .opacity(createError ? 1 : 0)
                .foregroundStyle(Color.red)
            
            HStack(spacing: 10) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                }
                
                Button(action: {
                    createError = true
                }) {
                    Text("Test Error")
                }
                
                Button(action: {
                    addTeam()
                    if !createError {
                        isPresented = false
                    }
                }) {
                    Text("Submit")
                }
            }
        }
        .padding()
    }
    
    func addTeam() {
        // Obtain a unique team identifier and set this as the team ID. If a team name is not specified, then the team name corresponds to its ID.
        let teamID = Team.getUniqueId()
        if teamName.isEmpty {
            teamName = "Team \(teamID)"
        }
        let newTeam = Team(id: teamID, name: teamName, isFavourite: false, pokemonIDs: [1024])
        createError = !database.addTeam(newTeam)
    }
}
