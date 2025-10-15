//
//  StringExtension.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import Foundation
extension String {
    func readableFormat() -> String {
        self
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    func apiPokemonFormat() -> String {
        let baseString = self
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
        return baseString.hasPrefix("ogerpon-") ? baseString + "-mask" : baseString
    }

    func apiItemFormat() -> String {
        self
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
    }
}
