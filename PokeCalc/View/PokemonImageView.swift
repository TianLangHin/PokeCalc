//
//  PokemonImageView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

struct PokemonImageView: View {
    @State var pokemonNumber: Int
    
    var body: some View {
        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
            case .failure:
                Image("0")
            @unknown default:
                Image("0")
            }
        }
    }
}
