//
//  MoveChooserView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

/// This is a sub-view that allows the user to select a move to add to a particular Pokemon.
struct MoveChooserView: View {
    // The database environment variable is here only to be passed to the MoveLookupView,
    // so that the child view can automatically add the selected move to the Pokemon.
    @EnvironmentObject var database: DatabaseViewModel

    // The move string is also passed to the View so that the UI of the parent view can be updated easily.
    @Binding var move: String

    // In addition to the move, the ID (primary key) of the edited Pokemon,
    // the move list available to the Pokemon, and the current index of the move is stored
    // to be passed further down to the child view for correctly modifying the state.
    let pokemonID: Int
    let moveList: [String]
    let currentMoveNum: Int

    var body: some View {
        NavigationLink {
            // The child view is navigated to through this link.
            MoveLookupView(
                currentMove: $move,
                moveList: moveList,
                pokemonID: pokemonID,
                currentMoveNum: currentMoveNum)
                .environmentObject(database)
        } label: {
            // A right-facing chevron is used as an icon to indicate
            // that the move is selectable and customisable.
            HStack(spacing: 10) {
                Text("Move \(currentMoveNum):")
                    .foregroundStyle(.black)
                Spacer()
                Text(move == "" ? "Select a Move" : move.readableFormat())
                Image(systemName: "chevron.right")
            }
            .padding(20)
            .padding(.horizontal, 5)
            .background(
                // The background is also made to be a consistent grey rectangle
                // for better UI element distinction.
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .fill(Color.gray.opacity(0.05))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
            )
            .cornerRadius(8)
        }
    }
}
