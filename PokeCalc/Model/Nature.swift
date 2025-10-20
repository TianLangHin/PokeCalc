//
//  Nature.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 16/10/2025.
//

/// This global constant is a list of all Pokémon natures,
/// arranged in the order such that the nature at index `i`
/// enhances stat number `i / 5` and reduces stat number `i % 5`,
/// where the values `0`, `1`, `2`, `3`, and `4` correspond to
/// HP, Attack, Defense, Special Attack, and Special Defense respectively.
let POKEMON_NATURES = [
    "Hardy", "Lonely", "Adamant", "Naughty", "Brave",
    "Bold", "Docile", "Impish", "Lax", "Relaxed",
    "Modest", "Mild", "Bashful", "Rash", "Quiet",
    "Calm", "Gentle", "Careful", "Quirky", "Sassy",
    "Timid", "Hasty", "Jolly", "Naive", "Serious"
]
