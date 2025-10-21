//
//  Team.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

/// This struct represents a customisable Pokémon team, consisting of at most 6 Pokemon.
/// The data within this struct will be persistently stored in the database,
/// and hence it conforms to `IDGeneratable` since this requires a unique primary key for each row.
struct Team: Hashable, IDGeneratable, Identifiable {
    let id: Int
    let name: String
    // The `isFavourite` flag determines the priority of displaying this team in the widget.
    var isFavourite: Bool
    // Each element in `pokemonIDs` is a foreign key,
    // being equal to the primary key of some row in the Pokemon table.
    var pokemonIDs: [Int]

    // Convenience function for getting the Pokémon at a particular position in the team,
    // since sometimes less than 6 Pokémon are contained.
    func getPokemonID(at index: Int) -> Int? {
        return self.pokemonIDs.count > index ? self.pokemonIDs[index] : nil
    }

    // Convenience functions for typical operations of adding a Pokémon and toggling a Boolean field.
    mutating func addPokemon(id: Int) {
        self.pokemonIDs.append(id)
    }

    mutating func toggleFavourite() {
        self.isFavourite.toggle()
    }

    // Domain-specific logic: a Pokémon team can have at most 6 Pokémon.
    static let maxPokemon = 6

    // To be used externally to only take at most the first six moves in a given Pokémon list.
    static func validPokemon(_ pokemonList: [Int]) -> [Int] {
        return Array(pokemonList.prefix(maxPokemon))
    }

    /// This portion conforms to the `IDGeneratable` protocol.
    /// The `Team` struct keeps a static internal counter for generating new IDs.
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
