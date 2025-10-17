//
//  MoveLookupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct MoveLookupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    @State var pokeID: Int
    @State var isLoaded = false
    @State var queryString: String = ""
    @State var moveListName: [String]
    @Binding var currentMove: String
    @State var currentMoveNum: Int
    
    var pokemon: Pokemon? {
        database.pokemon.first(where: { $0.id == pokeID })
    }
    
    var filteredMoves: [String] {
        return queryString == "" ? moveListName : self.filter(moveListName, on: queryString)
    }
    

    var body: some View {
        VStack {
            if isLoaded {
                TextField("Look for a Move...", text: $queryString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                List {
                    ForEach(filteredMoves, id: \.self) { move in
                        Button(action: {
                            if var pokemon = self.pokemon {
                                if pokemon.getMove(at: currentMoveNum - 1) != "" {
                                    pokemon.moves[currentMoveNum - 1] = move
                                } else {
                                    pokemon.moves.append(move)
                                }
                                dismiss()
                            } else if (pokeID == 0) {
                                currentMove = move
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text(move.readableFormat())
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }

            } else {
                ProgressView()
            }
        }
        .task {
            isLoaded = false
            
            isLoaded = true
        }
    }
    
    
    
    private func filter(_ data: [String], on query: String) -> [String] {
        return data.filter { item in
            item.lowercased().contains(query.lowercased().replacingOccurrences(of: " ", with: "-"))
        }
    }
}
