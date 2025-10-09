//
//  Team.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

struct Team: Hashable, IDGeneratable {
    let id: Int
    let name: String
    let isFavourite: Bool
    let pokemonIDs: [Int]

    func getPokemonID(at index: Int) -> Int? {
        return self.pokemonIDs.count > index ? self.pokemonIDs[index] : nil
    }

    static let maxPokemon = 6

    static func validPokemon(_ pokemonList: [Int]) -> [Int] {
        return Array(pokemonList.prefix(maxPokemon))
    }

    private static var nextId = 1

    static func getUniqueId() -> Int {
        let id = nextId
        nextId += 1
        return id
    }

    static func resetIdCounter(to maximum: Int) {
        nextId = maximum
    }
}
