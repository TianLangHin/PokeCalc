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
        if baseString.hasPrefix("ogerpon-") {
            return baseString + "-mask"
        } else if baseString.hasPrefix("indeedee-m") {
            return "indeedee-male"
        } else if baseString.hasPrefix("indeedee-f") {
            return "indeedee-female"
        } else {
            return baseString
        }
    }

    func apiGenericFormat() -> String {
        self
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
}
