//
//  SwipeTeamView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 17/10/2025.
//

import SwiftUI

/// This view appears as a UI element in the CalculationView,
/// allowing the user to swipe back and forth to navigate between the members of a team for a head-to-head comparison.
/// Swiping towards the left will navigate forward within the team, while swiping to the right will navigate backward.
struct SwipeTeamView: View {
    // To be able to retrieve the next `Pokemon` instance, the database is needed
    // since the `Team` instances only store the primary key of the corresponding instance.
    @EnvironmentObject var database: DatabaseViewModel

    // The Team is passed as a parameter this way so that this View will be re-rendered when the team changes.
    let team: Team

    // The parent View will keep track of the currently selected Pokemon,
    // which is represented as the integer index of the `pokemonIDs` array property.
    @Binding var selectedIndex: Int

    // This parameter is just to customise how much the user needs to swipe to navigate.
    let swipeDistance: CGFloat

    // This keeps track of the swipe gesture's progress so that the View knows when to render the Pokemon underneath.
    @State var offset = CGSize.zero

    // This keeps track of the index of the next Pokemon to navigate to given the gesture's movement direction.
    @State var bottomPokemonNumber: Int = 0

    // This computed property keeps track of the API number of the top Pokemon so that the proper image can be rendered.
    var pokemonNumber: Int {
        database.pokemon.first { $0.id == team.pokemonIDs[selectedIndex] }?.pokemonNumber ?? 0
    }

    // This is the swipe gesture that governs the change and rendering of the Pokemon images in this view.
    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Whenever a drag gesture occurs, set the `bottomPokemonNumber` state
                // depending on the direction of the drag.
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
                // Reset the top image back to the original location after the gesture ends.
                offset = CGSize.zero
            }
    }

    var body: some View {
        ZStack {
            // The Pokemon underneath the moveable one on top will have its image
            // be whatever the `bottomPokemonNumber` is, which could either be the next or previous Pokemon.
            PokemonImageView(pokemonNumber: bottomPokemonNumber)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                        .fill(.white)
                        .opacity(1)
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 5, x: 3, y: 3)
            // The Pokemon image on the top is the one that is moveable by the gesture,
            // and thus its offset is governed by the `offset` state.
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

    // To allow cyclical navigation, these functions allow the index to move
    // forward or backward within the indices of the `pokemonIDs` array.

    func nextIndex() -> Int {
        return (selectedIndex + 1) % team.pokemonIDs.count
    }

    func previousIndex() -> Int {
        return (selectedIndex + team.pokemonIDs.count - 1) % team.pokemonIDs.count
    }
}
