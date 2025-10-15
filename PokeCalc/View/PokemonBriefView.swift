//
//  PokemonBriefView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

struct PokemonBriefView: View {
    @EnvironmentObject var database: DatabaseViewModel

    @State var pokemonNumber: Int
    @State var pokemonName: String
    @State var team: Team?

    @State var isShowingSheet = false

    var body: some View {
        HStack {
            let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
            Text(pokemonName.stringConverter())
        }
        .onTapGesture {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            AddPokemonView(pokemonNumber: pokemonNumber, pokemonName: pokemonName, team: team)
                .environmentObject(database)
        }
    }
}
