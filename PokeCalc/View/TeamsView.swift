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
                            TeamDetailView(id: team.id)
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
            .popover(isPresented: $showPopup) {
                AddTeamView()
                    .environmentObject(database)
            }
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
