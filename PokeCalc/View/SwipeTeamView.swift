//
//  SwipeTeamView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 17/10/2025.
//

import SwiftUI

struct SwipeTeamView: View {
    @EnvironmentObject var database: DatabaseViewModel
    let team: Team

    @Binding var selectedIndex: Int
    @State var offset = CGSize.zero

    let size: CGFloat

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: value.translation.width, height: 0)
            }
            .onEnded { _ in
                let swipeDistance = size / 4
                if abs(offset.width) > swipeDistance {
                    selectedIndex = nextIndex()
                }
                offset = CGSize.zero
            }
    }

    var pokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[selectedIndex] }?.pokemonNumber ?? 0
    }

    var nextPokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[nextIndex()] }?.pokemonNumber ?? 0
    }

    var body: some View {
        // Does not work if the team is empty.
        ZStack {
            PokemonImageView(pokemonNumber: nextPokemonNumber)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .fill(.white)
                        .opacity(1)
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)
                .frame(width: size, height: size)
            PokemonImageView(pokemonNumber: pokemonNumber)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .fill(.white)
                        .opacity(1)
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 5, y: 5)
                .offset(offset)
                .gesture(swipeGesture)
                .frame(width: size, height: size)
        }
    }

    func nextIndex() -> Int {
        return (selectedIndex + 1) % team.pokemonIDs.count
    }
}
