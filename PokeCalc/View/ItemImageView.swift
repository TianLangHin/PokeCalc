//
//  ItemImageView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct ItemImageView: View {
    var item: String
    
    var itemName: String {
        item.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
    }
    
    var body: some View {
        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(itemName).png"
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
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
