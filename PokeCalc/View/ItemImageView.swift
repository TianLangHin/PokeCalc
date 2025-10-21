//
//  ItemImageView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

/// This is intended to be used as a sub-view that displays the sprite of a particular item.
struct ItemImageView: View {
    // The particular item to be displayed is passed as a string name.
    let item: String

    var itemName: String {
        item.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
    }

    var body: some View {
        // Since the sprite is available in the PokéAPI repository in a file of the item's name,
        // this URL is directly requested as part of the AsyncImage argument.
        // For better user experience in case AsyncImage fails to load (which can happen spontaneously),
        // a unique placeholder image is used.
        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(itemName).png"
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                // While the AsyncImage is loading, a ProgressView indicates its loading status.
                ProgressView()
            case .success(let image):
                image
            case .failure:
                Image("decamark")
            @unknown default:
                Image("decamark")
            }
        }
    }
}
