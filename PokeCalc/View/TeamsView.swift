//
//  TeamsView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

/// This view displays all the teams made by the user.
/// It also allows new ones to be added, clicking on teams for further editing,
/// and deleting them using the default List functionality.
struct TeamsView: View {
    // This view will need to update the database when a change is made by the user.
    @EnvironmentObject var database: DatabaseViewModel

    // This view also allows the user to search for teams,
    // and hence a String state containing the search query is needed.
    @State var searchQuery: String = ""

    // The pop up is shown when a new team is added (prompting for its name).
    @State var showPopup: Bool = false

    // If a database operation fails, a custom alert needs to be shown to the user.
    @State var alertText = ""
    @State var isAlerting = false

    // The list of teams that match the search query is a computed property.
    var filteredTeams: [Team] {
        if searchQuery.isEmpty {
            return database.teams
        }
        return database.teams.filter { team in
            team.name.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            if database.teams.isEmpty {
                // If there are no teams, a placeholder is shown to prompt the user
                // to make some.
                Spacer()
                Text("There are no teams currently stored. Start adding some with the + button!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                // If there are teams, list out all the teams for the user.
                List {
                    ForEach(filteredTeams, id: \.id) { team in
                        HStack {
                            // Each entry shows the name of the team
                            // as well as a button to toggle its favourite status.
                            Button {
                                toggleFavourite(id: team.id)
                            } label: {
                                Image(systemName: team.isFavourite ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            // When clicking on the entry,
                            // it opens up the TeamDetailView for the user to edit it.
                            NavigationLink {
                                TeamDetailView(team: team)
                            } label: {
                                Text(team.name)
                            }
                        }
                    }
                    .onDelete(perform: deleteTeam)
                    // This list also provides a functionality to delete teams.
                }
                .searchable(text: $searchQuery, prompt: "Search for Team")
                // To align UI across the app, the native searchable modifier is used.
            }
        }
        .task {
            // Upon startup, the database is refreshed.
            database.refresh()
        }
        .toolbar {
            // The toolbar shows the button for adding new Teams.
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPopup = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .popover(isPresented: $showPopup) {
            // This pop over will appear to allow the user to add a team.
            AddTeamView()
                .environmentObject(database)
        }
        .alert(alertText, isPresented: $isAlerting) {
            // The errors are presented as alerts to the user.
            Button("OK", role: .cancel) {}
        }
    }

    // This function deletes teams at the indices passed by the List
    // when the deletion is carried out.
    func deleteTeam(at offsets: IndexSet) {
        let teamsToDelete = offsets.map { filteredTeams[$0] }
        for team in teamsToDelete {
            // Each team deletion involves deleting the team from the Teams table
            // as well as the Pokemon referenced by it.
            let deleteSuccess = database.deleteTeam(by: team.id)
            if !deleteSuccess {
                alertText = "Could not remove team. Please try again later."
                isAlerting = true
            } else {
                for id in team.pokemonIDs {
                    let success = database.deletePokemon(by: id)
                    if !success {
                        alertText = "Team deletion unsuccessful. Please try again later."
                        isAlerting = true
                    }
                }
            }
        }
    }

    // Each button will update the Teams table by constructing
    // a new Team instance based on the team's ID and calling `updateTeam`.
    func toggleFavourite(id: Int) {
        if let index = database.teams.firstIndex(where: {$0.id == id}) {
            database.teams[index].toggleFavourite()
            let success = database.updateTeam(database.teams[index])
            if !success {
                alertText = "Could not update team favourite status. Please try again later."
                isAlerting = true
            }
        }
    }

}

#Preview {
    TeamsView()
        .environmentObject(DatabaseViewModel())
}
