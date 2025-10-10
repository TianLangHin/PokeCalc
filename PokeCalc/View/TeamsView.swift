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
    
    var body: some View {
        List {
            ForEach(database.teams, id: \.id) { team in
                HStack {
                    Text(team.name)
                    Spacer()
                    Image(systemName: (team.isFavourite ? "heart.fill" : "heart"))
                }
            }
        }
        .onAppear {
            Task {
                database.refresh()
            }
        }
        
         

    }
}


#Preview {
    
    TeamsView()
        .environmentObject(DatabaseViewModel())
}
