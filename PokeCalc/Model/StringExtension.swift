//
//  StringExtension.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import Foundation
extension String {
    func stringConverter() -> String {
        self
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
