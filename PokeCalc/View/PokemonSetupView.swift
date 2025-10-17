//
//  PokemonSetupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 17/10/2025.
//

import SwiftUI
import Foundation

struct PokemonSetupView: View {
    @EnvironmentObject var database: DatabaseViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var isShowing: Bool = false
    @State var isNotFilled: Bool = false
    
    
    
    var body: some View {
        List {
            ForEach(database.pokemon.filter { $0.pokemonNumber == pokemonNumber }, id:\.self) { pokemon in
                let team = database.teams.filter { $0.pokemonIDs.contains(pokemon.id) }.first!
                NavigationLink {
                    PokemonEditView(pokeID: pokemon.id, pokemonSpecies: pokemonName)
                        .environmentObject(database)
                        .presentationDragIndicator(.visible)
                } label: {
                    HStack {
                        PokemonImageView(pokemonNumber: pokemonNumber)
                        VStack {
                            Text(pokemonName.readableFormat())
                            Text("Team: \(team.name)")
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .task {
            database.refresh()
            if database.pokemon.filter({ $0.pokemonNumber == pokemonNumber }).isEmpty {
                isNotFilled = true
            }
        }
        .alert("There is no existing set for this Pokemon, please chose another one!", isPresented: $isNotFilled) {
            Button("Close", role: .cancel) {
                dismiss()
            }
        }
    }
}
