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
    @State var showAlert: Bool = false
    @State var deleteSuccess: Bool = false
    
    var filteredTeam: [Team] {
        if searchQuery.isEmpty {
            return database.teams
        }
        return database.filter(searchText: searchQuery)
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTeam, id: \.id) { team in
                    HStack {
                        NavigationLink {
                            TeamDetailView(team: team)
                        } label: {
                            Text(team.name)
                        }
                        Spacer()
                        Image(systemName: (team.isFavourite ? "heart.fill" : "heart"))
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
            
            Button(action: {
                self.showAlert = true
            }) {
                Text("Add New Team")
                    .padding()
                    .font(.headline)
            }
        }
        .alert("Enter New Team Name", isPresented: $showAlert) {
            TextField("Enter New Team Name...", text: $newName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("OK") {
                if !newName.isEmpty {
                    let team = Team(id: Team.getUniqueId(), name: newName, isFavourite: false, pokemonIDs: [1, 2, 3])
                    database.addTeam(team) // Dunno what to do with success rn here
                    newName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newName = ""
            }
        }
        
         

    }
    
    
    func deleteTeam(at offsets: IndexSet) {
        let teamsToDelete = offsets.map { filteredTeam[$0] }
        for team in teamsToDelete {
            deleteSuccess = database.deleteTeam(by: team.id)
        }
    }

}


#Preview {
    TeamsView()
        .environmentObject(DatabaseViewModel())
}
