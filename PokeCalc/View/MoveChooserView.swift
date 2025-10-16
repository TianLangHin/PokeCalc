//
//  MoveChooserView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct MoveChooserView: View {
    var pokeID: Int
    var moveListName: [String]
    @Binding var move: String
    var currentMoveNum: Int
    @EnvironmentObject var database: DatabaseViewModel
    
    var body: some View {
        NavigationLink {
            MoveLookupView(pokeID: pokeID, moveListName: moveListName, currentMove: $move, currentMoveNum: currentMoveNum)
                .environmentObject(database)
        } label: {
            HStack(spacing: 10) {
                Text("Move \(currentMoveNum):")
                Spacer()
                Text("\(move == "" ? "Select a Move" : move.readableFormat())")
                Image(systemName: "chevron.right")
            }
            .padding(20)
            .padding(.horizontal, 5)
            .background(
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
