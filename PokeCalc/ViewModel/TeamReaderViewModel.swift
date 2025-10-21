//
//  TeamReaderViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 13/10/2025.
//

import SwiftUI

/// This ViewModel provides the functionality of turning a text-form Pokemon team representation
/// into a valid app-internal representation. This is used within the Share Extension,
/// allowing users to share text from sites like PokéPaste and import Pokemon directly from text.
@Observable
class TeamReaderViewModel {
    // The regular expression used here captures all possible forms of the header of a Pokemon entry.
    let firstLineRegex = /^(.+?)(?:\s+[(]((?![MF])[A-Za-z0-9:\- ]+|[MF][A-Za-z0-9:\- ]+)[)])?(?:\s+[(](M|F)[)])?(?:\s+@\s+(.+))?\s*$/

    // The regular expression here captures elements of a slash-separated stat spread.
    let statComponentRegex = /\s*(\d+)\s(HP|Atk|Def|SpA|SpD|Spe)\s*/

    // There is also some information that we do not use within this app that we need to explicitly ignore
    // since it will otherwise be mistakenly recognised by `firstLineRegex`.
    let ignoredHeaders = ["Tera Type:", "Shiny:", "Happiness:", "Hidden Power:", "Dynamax Level:"]

    // The teams are read using the following idea:
    // each line in the text is either specifying a new attribute of an existing Pokemon,
    // or is marking the start of a new Pokemon.
    // Thus, each line in the text corresponds to an iteraation in a loop that either
    // modifies a persistent `PokemonEntry` data structure,
    // or will push the existing one into the list and start making a new one.
    func readTeam(_ teamString: String) -> [PokemonEntry] {
        // The lines of the text are extracted here.
        let lines = teamString.split(separator: "\n").map { line in
            String(line).replacingOccurrences(of: "  $", with: "", options: .regularExpression)
        }
        var team: [PokemonEntry] = []
        var currentPokemon: PokemonEntry = .empty

        for line in lines {
            // The other possible header structures are checked first before the `firstLineRegex`.
            if line.hasPrefix("Ability: ") {
                // This records the chosen Ability of the Pokemon.
                currentPokemon.ability = String(line.trimmingPrefix("Ability: "))
            } else if line.hasSuffix(" Nature") {
                // This records the chosen Nature of the Pokemon.
                let suffixIdx = line.index(line.endIndex, offsetBy: -7)
                currentPokemon.nature = String(line[..<suffixIdx])
            } else if line.hasPrefix("Level: ") {
                // This records the set Level of the Pokemon.
                let level = Int(String(line.trimmingPrefix("Level: "))) ?? 100
                currentPokemon.level = level
            } else if line.hasPrefix("EVs: ") {
                // Here, the stat distribution is slash-separated with spaces within each element
                // separating the integer and the stat name. (e.g., "4 HP / 252 Atk / 252 Spe")
                // The line is thus further split by the slash separator and the effort values are constructed
                // bit by bit using the `addStat` convenience function in `PokemonStats`.
                let evs = String(line.trimmingPrefix("EVs: "))
                for stat in evs.split(separator: "/").map({ String($0) }) {
                    if let match = try? statComponentRegex.firstMatch(in: stat) {
                        currentPokemon.effortValues.addStat(name: String(match.2), value: Int(String(match.1)) ?? 1)
                    }
                }
            } else if line.hasPrefix("IVs: ") {
                // Similar logic here with the EVs (previous case above).
                let ivs = String(line.trimmingPrefix("IVs: "))
                for stat in ivs.split(separator: "/").map({ String($0) }) {
                    if let match = try? statComponentRegex.firstMatch(in: stat) {
                        currentPokemon.individualValues.addStat(name: String(match.2), value: Int(String(match.1)) ?? 30)
                    }
                }
            } else if line.hasPrefix("- ") {
                // This records each of the moves in the Pokemon's moveset.
                currentPokemon.moves.append(String(line.trimmingPrefix("- ")))
            } else if !ignoredHeaders.allSatisfy({ header in !line.hasPrefix(header) }) {
                // To ensure the ignored headers (e.g., "Tera Type", "Happiness") are not mistakenly captured,
                // they are explicitly checked for. Since there is no function on an array that returns "any",
                // De Morgan's laws is used to invert the logic to use the "all" function here instead.
                continue
            } else if let match = try? firstLineRegex.firstMatch(in: line) {
                // When a new Pokemon is seen, push whatever was built previously to the list.
                if currentPokemon.species != "" {
                    team.append(currentPokemon)
                }
                currentPokemon = .empty
                // Now, read the line.
                currentPokemon.species = String(match.2 ?? match.1)
                currentPokemon.nickname = match.2.map { _ in String(match.1) }
                currentPokemon.gender = PokemonGender.from(string: match.3.map { String($0) })
                currentPokemon.item = match.4.map { String($0) }
            }
        }
        // Finally, the team text will end with a created Pokemon, so this final one is pushed as well.
        if currentPokemon.species != "" {
            team.append(currentPokemon)
        }
        return team
    }

    // Helper function to convert the raw data being read from the team text (which could contain invalid values)
    // into valid values that can be represented neatly in the app's native `Pokemon` struct representation.
    // Some additional data is required: `nameData` for the correct API number
    // and `id` for the primary key to be assigned to this new Pokemon.
    func newValidPokemon(from entry: PokemonEntry, nameData: [PokemonBriefData], id: Int) -> Pokemon? {
        let searchableEntry = entry.species.apiPokemonFormat()
        guard let pokemon = nameData.first(where: { $0.name == searchableEntry }) else {
            return nil
        }
        // The conventions of the strings to the API format are also conducted here
        // so that Pokemon made within the app and imported through the Share Extension
        // will have the same conventions in their String properties.
        return Pokemon(
            id: id,
            pokemonNumber: pokemon.apiID,
            item: entry.item?.apiGenericFormat() ?? "",
            level: Pokemon.validLevel(entry.level),
            ability: entry.ability?.apiGenericFormat() ?? "",
            effortValues: Pokemon.validEVs(entry.effortValues),
            nature: entry.nature,
            moves: Pokemon.validMoves(entry.moves.map { $0.apiGenericFormat() }))
    }

    // This struct represents the information available directly from the text-based representation of a team.
    // It is different from the `Pokemon` struct since that will require additional information
    // not inherently available to the text.
    struct PokemonEntry: Hashable {
        var species: String
        var nickname: String?
        var gender: PokemonGender?
        var item: String?
        var ability: String?
        var level: Int
        var effortValues: PokemonStats
        var individualValues: PokemonStats
        var nature: String
        var moves: [String]

        // This is a convenience property with common default values that are implied
        // in case certain values regarding the Pokemon are not specified within the imported team text.
        static var empty: PokemonEntry {
            PokemonEntry(
                species: "", nickname: nil, gender: nil, item: nil, ability: nil, level: 100,
                effortValues: .emptyEVs, individualValues: .emptyIVs,
                nature: "Serious", moves: [])
        }
    }

    // This struct represents one of the values that is accessible from the team text.
    // Although not directly used in the app yet, it could be used later in further extensions and development,
    // thus maximising extensibility.
    enum PokemonGender: Hashable {
        case male
        case female

        static func from(string: String?) -> PokemonGender? {
            switch string {
            case "M":
                return .male
            case "F":
                return .female
            default:
                return nil
            }
        }
    }
}
