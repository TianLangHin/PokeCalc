//
//  ItemLookupView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//


import SwiftUI

/// This is used as a page of its own to choose a particular item to attach to a Pokemon.
struct ItemLookupView: View {
    // This view will need to dismiss itself programmatically, hence this environment function is needed.
    @Environment(\.dismiss) var dismiss

    // This view will also need to modify the selected item state in the parent view, hence a Binding is given.
    @Binding var selectedItem: String

    // This View needs the ViewModel to display all possible items.
    @State var itemLookup = ItemsViewModel()
    // The `isLoaded` flag will cause a `ProgressView` to be displayed
    // before the asynchronous item data loading is completed.
    @State var isLoaded = false

    var body: some View {
        VStack {
            if isLoaded {
                // The content is shown only after the item data is loaded completely.
                TextField("Look for a Item...", text: $itemLookup.queryString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                List {
                    ForEach(itemLookup.filteredResults, id: \.self) { itemData in
                        // Each row is a button that sets the value of the binding to the respective item
                        // and then programmatically dismisses the View.
                        Button {
                            selectedItem = itemData
                            dismiss()
                        } label: {
                            // Both the item's sprite and its name is shown.
                            HStack {
                                ItemImageView(item: itemData)
                                Text(itemData.readableFormat())
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            } else {
                // Before the loading completes, the ProgressView is displayed to show that loading is in progress.
                ProgressView()
            }
        }
        .task {
            // Upon startup, the async loading of the items is started.
            isLoaded = false
            await itemLookup.loadItems()
            isLoaded = true
        }
    }
}

