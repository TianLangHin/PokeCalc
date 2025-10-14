//
//  TeamReaderViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 13/10/2025.
//

import SwiftUI

@Observable
class TeamReaderViewModel {
    let firstLineRegex = /^(.+?)(?:\s+[(]((?![MF])[A-Za-z0-9:\- ]+|[MF][A-Za-z0-9:\- ]+)[)])?(?:\s+[(](M|F)[)])?(?:\s+@\s+(.+))?\s*$/
    let statComponentRegex = /\s*(\d+)\s(HP|Atk|Def|SpA|SpD|Spe)\s*/
    let ignoredHeaders = ["Tera Type:", "Shiny:", "Happiness:", "Hidden Power:", "Dynamax Level:"]

    func readTeam(_ teamString: String) -> [PokemonEntry] {
        let lines = teamString.split(separator: "\n").map { line in
            String(line).replacingOccurrences(of: "  $", with: "", options: .regularExpression)
        }
        var team: [PokemonEntry] = []
        var currentPokemon: PokemonEntry = .empty
        for line in lines {
            if line.hasPrefix("Ability: ") {
                currentPokemon.ability = String(line.trimmingPrefix("Ability: "))
            } else if line.hasSuffix(" Nature") {
                let suffixIdx = line.index(line.endIndex, offsetBy: -7)
                currentPokemon.nature = String(line[..<suffixIdx])
            } else if line.hasPrefix("Level: ") {
                let level = Int(String(line.trimmingPrefix("Level: "))) ?? 100
                currentPokemon.level = level
            } else if line.hasPrefix("EVs: ") {
                let evs = String(line.trimmingPrefix("EVs: "))
                for stat in evs.split(separator: "/").map({ String($0) }) {
                    if let match = try? statComponentRegex.firstMatch(in: stat) {
                        currentPokemon.effortValues.addStat(name: String(match.2), value: Int(String(match.1)) ?? 1)
                    }
                }
            } else if line.hasPrefix("IVs: ") {
                let ivs = String(line.trimmingPrefix("IVs: "))
                for stat in ivs.split(separator: "/").map({ String($0) }) {
                    if let match = try? statComponentRegex.firstMatch(in: stat) {
                        currentPokemon.individualValues.addStat(name: String(match.2), value: Int(String(match.1)) ?? 30)
                    }
                }
            } else if line.hasPrefix("- ") {
                currentPokemon.moves.append(String(line.trimmingPrefix("- ")))
            } else if !ignoredHeaders.allSatisfy({ header in !line.hasPrefix(header) }) {
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
        if currentPokemon.species != "" {
            team.append(currentPokemon)
        }
        return team
    }

    func newValidPokemon(from entry: PokemonEntry, nameData: [PokemonBriefData], id: Int) -> Pokemon? {
        let searchableEntry = entry.species.lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
        guard let pokemon = nameData.first(where: { $0.name == searchableEntry }) else {
            return nil
        }
        return Pokemon(
            id: id, pokemonNumber: pokemon.apiID,
            item: entry.item ?? "", level: entry.level,
            ability: entry.ability ?? "",
            effortValues: entry.effortValues,
            nature: entry.nature, moves: entry.moves)
    }

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

        static var empty: PokemonEntry {
            PokemonEntry(
                species: "", nickname: nil, gender: nil, item: nil, ability: nil, level: 100,
                effortValues: .emptyEVs, individualValues: .emptyIVs,
                nature: "Serious", moves: [])
        }
    }

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
