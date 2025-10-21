//
//  Pokemon.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

/// This struct represents a customised Pokémon set that a user can create and store.
/// The data within this struct will be persistently stored in the database,
/// and hence it conforms to `IDGeneratable` since this requires a unique primary key for each row.
struct Pokemon: Hashable, IDGeneratable {
    // Each of these properties correspond to a column in the Pokemon table in the SQLite database.
    let id: Int

    // The `pokemonNumber` property is the ID which corresponds to the Pokemon's species
    // when looked up in PokéAPI. This bypasses needing to store redundant Pokemon data
    // that is fixed and not customisable.
    let pokemonNumber: Int

    // The rest of these are all Pokemon attributes that are customisable.
    var item: String
    var level: Int
    var ability: String
    var effortValues: PokemonStats
    var nature: String
    var moves: [String]

    // Convenience function for use in the UI when displaying the moves of a Pokemon,
    // since there is always at most 4, but sometimes less are stored.
    func getMove(at index: Int) -> String {
        return self.moves.count > index ? self.moves[index] : ""
    }

    // These are Pokémon domain-specific restrictions for the customisable values.
    static let maxLevel = 100
    static let minLevel = 1
    static let maxEVs = 252
    static let minEVs = 0
    static let maxMoves = 4

    // Some of the integer values stored must be within a certain range.
    // This convenience function for internal use forces a value to be within such a valid range.
    private static func clip(value: Int, lowerBound: Int, upperBound: Int) -> Int {
        return min(max(value, lowerBound), upperBound)
    }

    // To be used externally for clipping the value of an effort value.
    static func clipEV(value: Int) -> Int {
        return clip(value: value, lowerBound: minEVs, upperBound: maxEVs)
    }

    // To be used externally to set a potentially out-of-range value back to the 1-100 level range.
    static func validLevel(_ level: Int) -> Int {
        return clip(value: level, lowerBound: minLevel, upperBound: maxLevel)
    }

    // To be used externally to only take at most the first four moves in a given move list.
    // This is because Pokémon can have at most 4 moves.
    static func validMoves(_ moves: [String]) -> [String] {
        return Array(moves.prefix(maxMoves))
    }

    // To be used externally for clipping all effort values at once.
    static func validEVs(_ stats: PokemonStats) -> PokemonStats {
        return PokemonStats(
            hp: clipEV(value: stats.hp),
            attack: clipEV(value: stats.attack),
            defense: clipEV(value: stats.defense),
            specialAttack: clipEV(value: stats.specialAttack),
            specialDefense: clipEV(value: stats.specialDefense),
            speed: clipEV(value: stats.speed))
    }

    /// This portion conforms to the `IDGeneratable` protocol.
    /// The `Pokemon` struct keeps a static internal counter for generating new IDs.
    /// Every time `getUniqueId` is called, this counter is incremented so the next call
    /// does not output a clashing value. `resetIdCounter` allows this internal counter to be reset,
    /// at the potential risk of invalidation if not managed externally in a correct manner.
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
