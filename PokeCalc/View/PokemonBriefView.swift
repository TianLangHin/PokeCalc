//
//  PokemonBriefView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI

struct PokemonBriefView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @Binding var isDismiss: Bool
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
                    Image("0")
                @unknown default:
                    Image("0")
                }
            }
            Text(pokemonName.readableFormat())
        }
        .onTapGesture {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            AddPokemonView(isDismiss: $isDismiss, pokemonNumber: pokemonNumber, pokemonName: pokemonName, team: team)
                .environmentObject(database)
                .presentationDragIndicator(.visible)
        }
    }
}
