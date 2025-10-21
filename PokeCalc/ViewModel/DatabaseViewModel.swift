//
//  DatabaseViewModel.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import SwiftUI
import WidgetKit

/// This ViewModel acts as a wrapper around the `DatabaseController` class,
/// so that the updated version of the list of Pokemon and Teams will always be displayable in a View.
/// Only one instance of this class needs to be made, and it can be passed as an EnvironmentObject
/// to all Views in the app.
class DatabaseViewModel: ObservableObject {
    // This is the controller that the ViewModel wraps around.
    let dbController = DatabaseController()

    // These lists will always allow any View that accesses this ViewModel to
    // have updated information regarding all the Pokemon and Team instances currently in the database.
    @Published var pokemon: [Pokemon] = []
    @Published var teams: [Team] = []

    init() {
        // Upon initialisation, the stored data is loaded.
        self.refresh()
    }

    // This function refreshes the published Pokemon and Team lists by
    // fetching the data from the internal database again and populating the properties with the new values.
    // Additionally, it also resets the static `Pokemon` and `Team` internal counters for the primary key
    // to ensure that their generated keys are always unique relative to the current content of the database.
    func refresh() {
        self.pokemon = self.dbController.selectAllPokemon() ?? []
        let pokemonId = self.pokemon.map { $0.id }.max() ?? 0
        Pokemon.resetIdCounter(to: pokemonId + 1)
        self.teams = self.dbController.selectAllTeams() ?? []
        let teamId = self.teams.map { $0.id }.max() ?? 0
        Team.resetIdCounter(to: teamId + 1)
        // Finally, to keep the Widgets updated, every time a change is made in the database,
        // the Widgets are reloaded as well.
        WidgetCenter.shared.reloadAllTimelines()
    }

    // The next methods are all simple wrappers to the functionality of `DatabaseController`,
    // while still returning the success flags and refreshing the published Pokemon and Team lists each time.

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
        let success1 = self.dbController.deleteAllTeams()
        let success2 = self.dbController.deleteAllPokemon()
        self.refresh()
        return success1 && success2
    }
}
