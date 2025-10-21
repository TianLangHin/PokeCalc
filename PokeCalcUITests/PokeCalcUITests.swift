//
//  PokeCalcUITests.swift
//  PokeCalcUITests
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import XCTest

final class PokeCalcUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    @MainActor
    func testTeamCreation() throws {
        // The name of the team used to test the UI with.
        let testTeamName = "testTeamCreation"

        // Launch the app.
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Teams tab.
        app.tabBars["Tab Bar"].buttons["Teams"].tap()

        // Add a new team of name "testTeamCreation".
        app.navigationBars["Teams"].buttons["plus"].tap()
        app.textFields["Enter Team Name..."].tap()
        app.textFields["Enter Team Name..."].typeText(testTeamName)
        app.buttons["Add Team!"].tap()

        // Navigate into the TeamDetailView for that team.
        app.collectionViews.buttons[testTeamName].tap()
        // Navigate back.
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Teams"].tap()

        // Delete the team.
        app.collectionViews.buttons[testTeamName].swipeLeft()
        app.buttons["Delete"].tap()
    }

    @MainActor
    func testDuplicateTeamCreation() throws {
        // The name of the team used to test the UI with.
        let testTeamName = "testDuplicateTeamCreation"

        // Launch the app.
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Teams tab.
        app.tabBars["Tab Bar"].buttons["Teams"].tap()

        // Add a new team of name "testDuplicateTeamCreation".
        app.navigationBars["Teams"].buttons["plus"].tap()
        let textField = app.textFields["Enter Team Name..."]
        textField.tap()
        textField.typeText(testTeamName)
        app.buttons["Add Team!"].tap()

        // Navigate into the TeamDetailView for that team.
        app.collectionViews.buttons[testTeamName].tap()
        // Navigate back.
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Teams"].tap()

        // Try adding a team of the same name again.
        app.navigationBars["Teams"].buttons["plus"].tap()
        textField.tap()
        textField.typeText(testTeamName)
        app.buttons["Add Team!"].tap()

        // Test to see if the error message has popped up.
        app.staticTexts["This team name already exists. Please enter another name."].tap()
        // Cancel the team addition.
        app.buttons["Cancel"].tap()

        // Delete the team.
        app.collectionViews.buttons["testDuplicateTeamCreation"].swipeLeft()
        app.buttons["Delete"].tap()
    }

    @MainActor
    func testPokemonLookupAlert() throws {
        // Launch the app.
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Pokémon tab.
        app.tabBars["Tab Bar"].buttons["Pokémon"].tap()

        // Enter the prefix of a Pokemon (which has no entries) into the search bar and tap the Pokemon that appears.
        let searchField = app.navigationBars["Pokémon Lookup"].searchFields["Look for an existing Pokémon setup..."]
        searchField.tap()
        searchField.typeText("Pincur")
        app.collectionViews.buttons["Pincurchin"].tap()

        // Check whether there is an alert stating there is no such Pokemon entry.
        let alertText = "There is no existing set for this Pokémon, please chose another one!"
        app.alerts[alertText].scrollViews.otherElements.buttons["Close"].tap()
    }

    @MainActor
    func testAddPokemonToTeam() throws {
        // The name of the team used to test the UI with.
        let testTeamName = "testAddPokemonToTeam"

        // Launch the app.
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Teams tab.
        app.tabBars["Tab Bar"].buttons["Teams"].tap()

        // Adds the new team.
        app.navigationBars["Teams"].buttons["plus"].tap()
        let textField = app.textFields["Enter Team Name..."]
        textField.tap()
        textField.typeText(testTeamName)
        app.buttons["Add Team!"].tap()

        // Navigate to the TeamDetailView.
        app.collectionViews.buttons[testTeamName].tap()

        // Navigate to the PokemonLookupView.
        app.buttons["plus"].tap()

        // Search for a Miraidon (Pokémon).
        app.collectionViews.buttons["Bulbasaur"].swipeDown()
        let searchField = app.searchFields["Look for a Pokémon..."]
        searchField.tap()
        searchField.typeText("Mirai")
        // This here will check that the lookup function works.
        app.collectionViews.buttons["Miraidon"].tap()
        app.buttons["Add Pokémon"].tap()

        // Toggle the favourite status of the team.
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["heart"].tap()
        // Finally, navigate back.
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Teams"].tap()
        // And then delete the team.
        app.collectionViews.buttons[testTeamName].swipeLeft()
        app.buttons["Delete"].tap()
    }

    @MainActor
    func testValidHPGauge() throws {
        // Launch the app.
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Calculator tab.
        app.tabBars["Tab Bar"].buttons["Calculator"].tap()

        // Show that the HP Gauge starts at 100%.
        app.otherElements["Remaining HP: 100%, No damage was taken!"].tap()

        // Swipe to change the Pokemon selected.
        app.windows.children(matching: .other).element.swipeLeft()
        app.windows.children(matching: .other).element.swipeLeft()
        app.windows.children(matching: .other).element.swipeLeft()

        // Show that the HP Gauge remains at 100%.
        app.otherElements["Remaining HP: 100%, No damage was taken!"].tap()
    }
}
