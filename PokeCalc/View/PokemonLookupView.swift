//
//  PokemonLookupView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

struct PokemonLookupView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @Environment(\.dismiss) var dismiss
    @State var isDismiss: Bool = false
    @State var namesLookup = PokemonNamesViewModel()
    @State var team: Team?
    @State var isLoaded = false

    var body: some View {
        VStack {
            if isLoaded {
                TextField("Look for a Pokémon...", text: $namesLookup.queryString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                List {
                    ForEach(namesLookup.filteredResults, id: \.self) { pokemonData in
                        PokemonBriefView(isDismiss: $isDismiss, pokemonNumber: pokemonData.apiID, pokemonName: pokemonData.name, team: team)
                            .environmentObject(database)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            isLoaded = false
            await namesLookup.loadNames()
            isLoaded = true
        }
        .onChange(of: isDismiss) { oldValue, newValue in
            if newValue {
               dismissSelf()
            }
        }
    }
    
    
    func dismissSelf() {
        isDismiss = false
        dismiss()
    }
}
