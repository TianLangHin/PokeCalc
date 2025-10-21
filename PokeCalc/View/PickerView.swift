//
//  PickerView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

/// This view is used for selecting from a list of different values using a pop-up picker.
/// In this app, it is currently used only for abilities and natures.
struct PickerView: View {
    // This view will have to modify a state in a parent state, and thus a binding is needed.
    @Binding var selection: String

    // Additionally, the list of possible selections as well as the title
    // (i.e., the type of value being chosen) needs to be displayed.
    let listOfItems: [String]
    let pickerTitle: String

    var body: some View {
        HStack {
            // The picker title is shown on the left.
            Text(pickerTitle)
            Spacer()
            // The Picker on the right is wrapped inside a Menu so that the text selection
            // (regardless of length) is displayed in one line.
            Menu {
                Picker(selection: $selection, label: Text("")) {
                    ForEach(listOfItems.sorted(), id: \.self) { item in
                        // The tag is used here to ensure the selection is always known to the program.
                        Text(item.readableFormat()).tag(item)
                    }
                }
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    Text(selection.readableFormat())
                    // The vertical stack of up and down chevrons indicates the clickability of the picker.
                    VStack {
                        Image(systemName: "chevron.up")
                        Image(systemName: "chevron.down")
                    }
                }
            }
        }
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
        // This styling used for the overall picker makes the view stand out as a distinctive UI element.
    }
}
