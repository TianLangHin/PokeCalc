//
//  PickerView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct PickerView: View {
    @Binding var selection: String
    var listOfItems: [String]
    var pickerTitle: String
    
    
    var body: some View {
        HStack {
            Text("\(pickerTitle)")
            
            Spacer()
            Picker(selection: $selection, label: Text("")) {
                ForEach(listOfItems.sorted(), id: \.self) { item in
                    Text(item.readableFormat()).tag(item)
                }
            }
            .pickerStyle(.automatic)
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
    }
}
