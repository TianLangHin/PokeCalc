//
//  Pokemon.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

struct Pokemon: Hashable, IDGeneratable {
    let id: Int
    let pokemonNumber: Int
    let item: String
    let level: Int
    let effortValues: PokemonStats
    let nature: String
    let moves: [String]

    func getMove(at index: Int) -> String {
        return self.moves.count > index ? self.moves[index] : ""
    }

    static let maxLevel = 100
    static let minLevel = 1
    static let maxEVs = 252
    static let minEVs = 0
    static let maxMoves = 4

    private static func clip(value: Int, lowerBound: Int, upperBound: Int) -> Int {
        return min(max(value, lowerBound), upperBound)
    }

    static func validLevel(_ level: Int) -> Int {
        return clip(value: level, lowerBound: minLevel, upperBound: maxLevel)
    }

    static func validMoves(_ moves: [String]) -> [String] {
        return Array(moves.prefix(maxMoves))
    }

    static func validEVs(_ stats: PokemonStats) -> PokemonStats {
        return PokemonStats(
            hp: clip(value: stats.hp, lowerBound: minEVs, upperBound: maxEVs),
            attack: clip(value: stats.attack, lowerBound: minEVs, upperBound: maxEVs),
            defense: clip(value: stats.defense, lowerBound: minEVs, upperBound: maxEVs),
            specialAttack: clip(value: stats.specialAttack, lowerBound: minEVs, upperBound: maxEVs),
            specialDefense: clip(value: stats.specialDefense, lowerBound: minEVs, upperBound: maxEVs),
            speed: clip(value: stats.speed, lowerBound: minEVs, upperBound: maxEVs))
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
