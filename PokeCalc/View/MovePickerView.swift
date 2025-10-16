//
//  MovePickerView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct MovePickerView: View {
    let title: String
    @Binding var selection: String
    let allMoves: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $selection, label:
                HStack {
                    Text(selection.isEmpty ? "Select \(title)" : "\(title)")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
            ) {
                ForEach(["None"] + allMoves, id: \.self) { move in
                    Text(move.isEmpty ? "None" : move.readableFormat()).tag(move)
                        .foregroundStyle(.black)
                }
            }
            .pickerStyle(.navigationLink)
            .padding(20)
            .padding(.horizontal, 5)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
            )
        }
    }
}

