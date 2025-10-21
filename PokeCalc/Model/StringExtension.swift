//
//  StringExtension.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import Foundation

/// These String extensions allow easy conversion between different string formats throughout the app.
/// This is due to the difference between PokéPaste/Showdown formats (imports via Share Extension),
/// PokéAPI conventions, and typical human-readable formats.
extension String {
    // Converts strings from the PokéAPI format into a human-readable format.
    func readableFormat() -> String {
        // This converts lowercase Kebab-case into capitalised space-separated words.
        self
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    // Converts strings representing Pokémon from either
    // a human-readable format or PokéPaste format into the PokéAPI format.
    func apiPokemonFormat() -> String {
        // Generally, this conversion involves converting capitalised space-separated words into Kebab-case.
        let baseString = self
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")

        // However, some specific Pokémon have extra logic required for this conversion
        // due to the convention of PokéAPI.
        if baseString.hasPrefix("ogerpon-") {
            return baseString + "-mask"
        } else if baseString.hasPrefix("indeedee-m") {
            return "indeedee-male"
        } else if baseString.hasPrefix("indeedee-f") {
            return "indeedee-female"
        } else if baseString.hasPrefix("arceus") {
            return "arceus"
        } else if baseString.hasPrefix("necrozma-dusk-mane") {
            return "necrozma-dusk"
        } else if baseString.hasPrefix("necrozma-dawn-mane") {
            return "necrozma-dawn"
        } else {
            return baseString
        }
    }

    // Converts all strings except those representing Pokémon from a human-readable format
    // into the PokéAPI format. This is used for items, abilities and moves.
    func apiGenericFormat() -> String {
        // Similar conversion to Kebab-case, with the added logic of removing apostrophes and brackets.
        self
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
}
