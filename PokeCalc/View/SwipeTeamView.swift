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

    let swipeDistance: CGFloat

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: value.translation.width, height: 0)
                let bottomIndex = offset.width < 0 ? nextIndex() : previousIndex()
                bottomPokemonNumber = database.pokemon.first { $0.id == team.pokemonIDs[bottomIndex] }?.pokemonNumber ?? 0
            }
            .onEnded { _ in
                if offset.width < -swipeDistance {
                    // Swiping the top item to the left indicates forward progression.
                    // Here, the offset is in the negative x-direction.
                    selectedIndex = nextIndex()
                } else if offset.width > swipeDistance {
                    // Swiping the top item to the right indicates backward navigation.
                    // Here, the offset is in the positive x-direction.
                    selectedIndex = previousIndex()
                }
                offset = CGSize.zero
            }
    }

    var pokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[selectedIndex] }?.pokemonNumber ?? 0
    }

    @State var bottomPokemonNumber: Int = 0

    var body: some View {
        // Does not work if the team is empty.
        ZStack {
            PokemonImageView(pokemonNumber: bottomPokemonNumber)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .fill(.white)
                        .opacity(1)
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 3, y: 3)
            PokemonImageView(pokemonNumber: pokemonNumber)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .fill(.white)
                        .opacity(1)
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 3, y: 3)
                .offset(offset)
                .gesture(swipeGesture)
        }
    }

    func nextIndex() -> Int {
        return (selectedIndex + 1) % team.pokemonIDs.count
    }

    func previousIndex() -> Int {
        return (selectedIndex + team.pokemonIDs.count - 1) % team.pokemonIDs.count
    }
}
