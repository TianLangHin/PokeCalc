//
//  PokemonImageView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

import Foundation
import SwiftUI

/// This is intended as a small UI element that has intuitive placeholders for invalid Pokemon
/// or AsyncImage malfunctions. It displays the sprite of the Pokémon that has the corresponding `pokemonNumber`
/// as its index in PokéAPI.
struct PokemonImageView: View {
    // This is passed as a parameter so that this image will be re-rendered whenever the selected Pokémon changes.
    var pokemonNumber: Int

    var body: some View {
        // The Pokémon's API index is needed since it is used to find the sprite URL from the PokéAPI repository.
        let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
            case .failure:
                // The "0" image is fetched from the usage of a `0.png` request, but stored locally for easier access.
                Image("0")
            @unknown default:
                Image("0")
            }
        }
    }
}
