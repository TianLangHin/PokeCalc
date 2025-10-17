//
//  SwipeTeamView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 17/10/2025.
//

import SwiftUI

struct SwipeTeamView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @State var team: Team

    @Binding var selectedPokemon: Int
    @State var offset = CGSize.zero

    let size: CGFloat

    var swipeDistance: CGFloat {
        size / 4
    }

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: value.translation.width, height: 0)
            }
            .onEnded { _ in
                if abs(offset.width) > swipeDistance {
                    selectedPokemon = nextSelectedPokemon()
                }
                offset = CGSize.zero
            }
    }

    var pokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[selectedPokemon] }?.pokemonNumber ?? 1
    }

    var nextPokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[nextSelectedPokemon()] }?.pokemonNumber ?? 1
    }

    var body: some View {
        // Does not work if the team is empty.
        ZStack {
            PokemonImageView(pokemonNumber: nextPokemonNumber)
                .frame(width: size, height: size)
            PokemonImageView(pokemonNumber: pokemonNumber)
                .background(Rectangle().fill(.white).opacity(1))
                .offset(offset)
                .gesture(swipeGesture)
                .frame(width: size, height: size)
        }
    }

    func nextSelectedPokemon() -> Int {
        return (selectedPokemon + 1) % team.pokemonIDs.count
    }
}
