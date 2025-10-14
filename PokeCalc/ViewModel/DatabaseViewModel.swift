//
//  DatabaseViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI
import WidgetKit

class DatabaseViewModel: ObservableObject {
    let dbController = DatabaseController()

    @Published var pokemon: [Pokemon] = []
    @Published var teams: [Team] = []

    init() {
        self.refresh()
    }

    func addPokemon(_ pokemon: Pokemon) -> Bool {
        let success = self.dbController.insertPokemon(pokemon)
        self.refresh()
        return success
    }

    func addTeam(_ team: Team) -> Bool {
        let success = self.dbController.insertTeam(team)
        self.refresh()
        return success
    }

    func updatePokemon(_ pokemon: Pokemon) -> Bool {
        let success = self.dbController.updatePokemon(pokemon)
        self.refresh()
        return success
    }

    func updateTeam(_ team: Team) -> Bool {
        let success = self.dbController.updateTeam(team)
        self.refresh()
        return success
    }

    func deletePokemon(by id: Int) -> Bool {
        let success = self.dbController.deletePokemon(by: id)
        self.refresh()
        return success
    }

    func deleteTeam(by id: Int) -> Bool {
        let success = self.dbController.deleteTeam(by: id)
        self.refresh()
        return success
    }

    func clear() -> Bool {
        let success1 = self.dbController.deleteAllPokemon()
        let success2 = self.dbController.deleteAllTeams()
        self.refresh()
        return success1 && success2
    }

    func refresh() {
        self.pokemon = self.dbController.selectAllPokemon() ?? []
        let pokemonId = self.pokemon.map { $0.id }.max() ?? 0
        Pokemon.resetIdCounter(to: pokemonId + 1)
        self.teams = self.dbController.selectAllTeams() ?? []
        let teamId = self.teams.map { $0.id }.max() ?? 0
        Team.resetIdCounter(to: teamId + 1)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    
    
    func filter(searchText: String) -> [Team] {
        var filteredTeam: [Team] = []
        for team in self.teams {
            if (team.name.lowercased().contains(searchText.lowercased())) == true {
                filteredTeam.append(team)
            }
        }
        return filteredTeam
    }
}
