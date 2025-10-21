//
//  MoveLookupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

/// This is a view that shows the list of possible moves from which the user can choose from,
/// and allows the user to select one to add to a Pokemon.
struct MoveLookupView: View {
    // This view needs to programmatically dismiss itself, hence the environment function is given.
    @EnvironmentObject var database: DatabaseViewModel
    @Environment(\.dismiss) var dismiss

    // This view will also edit a particular Pokemon move in the parent view,
    // hence a binding is needed. The list of all possible moves is also provided.
    @Binding var currentMove: String
    @State var moveList: [String]

    // The ID of the current Pokemon being edited is also needed for immediate parent view updates.
    @State var pokemonID: Int

    // The current move being edited is also required.
    @State var currentMoveNum: Int

    // Since this view will have searching capabilities,
    // a state to keep track of the searching keyword is made.
    @State var queryString: String = ""

    // The list of moves filtered on the search (given by `queryString`) is a computed property.
    var filteredMoves: [String] {
        return queryString == "" ? moveList : self.filter(moveList, on: queryString)
    }

    var body: some View {
        VStack {
            // The content is shown only after the move list data is loaded completely.
            TextField("Look for a Move...", text: $queryString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
            List {
                ForEach(filteredMoves, id: \.self) { move in
                    Button {
                        // The binding is updated when a move is selected.
                        if var pokemon = database.pokemon.first(where: { $0.id == pokemonID }) {
                            if pokemon.getMove(at: currentMoveNum - 1) != "" {
                                pokemon.moves[currentMoveNum - 1] = move
                            } else {
                                pokemon.moves.append(move)
                            }
                            dismiss()
                        } else if pokemonID == 0 {
                            currentMove = move
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text(move.readableFormat())
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
        }
    }

    // Convenience function to abstract the filtering logic away from the computed property itself.
    private func filter(_ data: [String], on query: String) -> [String] {
        return data.filter { item in
            item.lowercased().contains(query.lowercased().replacingOccurrences(of: " ", with: "-"))
        }
    }
}
