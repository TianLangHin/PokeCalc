//
//  ColorExtension.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//


import Foundation
import SwiftUI

extension Color {
    static let primary: Color = .init(hex: 0x3b3b3b)
    
    init(hex: Int) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double((hex >> 0) & 0xff) / 255,
            opacity: 1
        )
    }

    static func getBackgroundColour(type: String) -> Color {
        switch type {
        case "normal":
            return Color(hex: 0xA8A77A)
        case "fighting":
            return Color(hex: 0xC22E28)
        case "flying":
            return Color(hex: 0xA98FF3)
        case "poison":
            return Color(hex: 0xA33EA1)
        case "ground":
            return Color(hex: 0xE2BF65)
        case "rock":
            return Color(hex: 0xB6A136)
        case "bug":
            return Color(hex: 0xA6B91A)
        case "steel":
            return Color(hex: 0xB7B7CE)
        case "ghost":
            return Color(hex: 0x735797)
        case "fire":
            return Color(hex: 0xEE8130)
        case "water":
            return Color(hex: 0x6390F0)
        case "grass":
            return Color(hex: 0x7AC74C)
        case "electric":
            return Color(hex: 0xF7D02C)
        case "psychic":
            return Color(hex: 0xF95587)
        case "ice":
            return Color(hex: 0x96D9D6)
        case "dragon":
            return Color(hex: 0x6F35FC)
        case "dark":
            return Color(hex: 0x705746)
        case "fairy":
            return Color(hex: 0xD685AD)
        default:
            return Color.clear
        }
    }
    
    // Colours for the foreground text when put against the above background color,
    // designed to maximise contrast with the background colour.
    static func getForegroundColour(type: String) -> Color {
        switch type {
        case "normal":
            return Color.white
        case "fighting":
            return Color.white
        case "flying":
            return Color.black
        case "poison":
            return Color.white
        case "ground":
            return Color.black
        case "rock":
            return Color.white
        case "bug":
            return Color.white
        case "steel":
            return Color.black
        case "ghost":
            return Color.white
        case "fire":
            return Color.black
        case "water":
            return Color.black
        case "grass":
            return Color.black
        case "electric":
            return Color.black
        case "psychic":
            return Color.white
        case "ice":
            return Color.black
        case "dragon":
            return Color.white
        case "dark":
            return Color.white
        case "fairy":
            return Color.black
        default:
            return Color.clear
        }
    }

    // These stat colours are taken from the pokepast.es syntax-eviv.css style sheet,
    // which assigns each stat its own colour for visual distinction.
    static func getStatColour(stat: String) -> Color {
        switch stat {
        case "HP": return Color(hex: 0xFF0000)
        case "Atk": return Color(hex: 0xF08030)
        case "Def": return Color(hex: 0xF8D030)
        case "SpA": return Color(hex: 0x6890F0)
        case "SpD": return Color(hex: 0x78C850)
        case "Spe": return Color(hex: 0xF85888)
        default: return Color.gray
        }
    }
}
