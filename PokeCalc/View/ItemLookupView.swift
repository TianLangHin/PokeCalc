//
//  ItemLookupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//


import SwiftUI

struct ItemLookupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var database: DatabaseViewModel

    @State var itemLookup = ItemsViewModel()
    @State var isLoaded = false
    @Binding var itemTF: String

    var body: some View {
        VStack {
            if isLoaded {
                TextField("Look for a Item...", text: $itemLookup.queryString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                List {
                    ForEach(itemLookup.filteredResults, id: \.self) { itemData in
                        Button(action: {
                            itemTF = itemData
                            dismiss()
                        }) {
                            HStack {
                                ItemImageView(item: itemData)
                                Text(itemData.readableFormat())
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
            await itemLookup.loadItems()
            isLoaded = true
        }
    }
}

