//
//  TeamsView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

struct TeamsView: View {
    @EnvironmentObject var database: DatabaseViewModel

    @State var searchQuery: String = ""
    @State var newName: String = ""
    @State var showPopup: Bool = false
    @State var showAlert: Bool = false

    @State var alertText = ""
    @State var isAlerting = false

    var filteredTeam: [Team] {
        if searchQuery.isEmpty {
            return database.teams
        }
        return database.teams.filter { team in
            team.name.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTeam, id: \.id) { team in
                    HStack {
                        Button (action: {
                            toggleFavourite(id: team.id)
                        }) {
                            Image(systemName: (team.isFavourite ? "heart.fill" : "heart"))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        NavigationLink {
                            TeamDetailView(team: team)
                        } label: {
                            Text(team.name)
                        }
                    }
                }
                .onDelete(perform: deleteTeam)
                .onAppear {
                    Task {
                        database.refresh()
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Search for Team")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    showPopup = true
                }) {
                    Image(systemName: "plus")
                }
                
            }
        }
        .popover(isPresented: $showPopup) {
            AddTeamView()
                .environmentObject(database)
        }
        .alert(alertText, isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    func deleteTeam(at offsets: IndexSet) {
        let teamsToDelete = offsets.map { filteredTeam[$0] }
        for team in teamsToDelete {
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
