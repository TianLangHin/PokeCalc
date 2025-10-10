//
//  TeamDetailView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 10/10/2025.
//

import SwiftUI
import Foundation

struct TeamDetailView: View {
    @State var team: Team
    
    var body: some View {
        List {
            ForEach(team.pokemonIDs, id:\.self) { id in
                Text("Pokemon Number: \(id)")
            }
        }
    }
}

#Preview {
    TeamDetailView(team: Team(id: Team.getUniqueId(), name: "Team", isFavourite: false, pokemonIDs: [1000, 100+1, 100+2]))
}
