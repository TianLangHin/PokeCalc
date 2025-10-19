//
//  PokeCalcTests.swift
//  PokeCalcTests
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import XCTest
@testable import PokeCalc

final class PokeCalcTests: XCTestCase {

    // Here, some dummy data for database testing is defined which are used in more than one test case.
    // Since the variables are all value-types, no shared references or data races will occur.
    let pokemon1 = Pokemon(
        id: 1, pokemonNumber: 1, item: "a", level: 1, ability: "A", effortValues: .emptyEVs, nature: "", moves: [])
    let pokemon2 = Pokemon(
        id: 2, pokemonNumber: 2, item: "b", level: 1, ability: "B", effortValues: .emptyEVs, nature: "", moves: [])
    let team1 = Team(id: 1, name: "team1", isFavourite: false, pokemonIDs: [1, 2])
    let team2 = Team(id: 2, name: "team1", isFavourite: false, pokemonIDs: [1, 2])

    let newPokemon1 = Pokemon(
        id: 1, pokemonNumber: 1, item: "c", level: 1, ability: "C", effortValues: .emptyIVs, nature: "", moves: [])
    let newPokemon2 = Pokemon(
        id: 2, pokemonNumber: 2, item: "d", level: 1, ability: "D", effortValues: .emptyIVs, nature: "", moves: [])
    let newTeam1 = Team(id: 1, name: "new team 1", isFavourite: true, pokemonIDs: [1, 2])
        let newTeam2 = Team(id: 2, name: "new team 2", isFavourite: true, pokemonIDs: [1, 2])

    override func setUpWithError() throws {
        // We call the parent implementation of this function each time before the test runs.
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // We call the parent implementation of this function each time after the test concludes.
        try super.tearDownWithError()
    }

    /// This function tests whether a new instance of the database can be loaded without problem.
    func testDatabaseInitialisationWorks() {
        // To separate the testing from the production database, a different `dbName` argument is passed.
        let db = DatabaseController(dbName: "Initialisation.sqlite")
        // This is the only assertion made here, since the test is very basic.
        XCTAssertTrue(db.success)
    }

    /// This function tests whether data can be persisted and recovered after insertion into the database.
    func testDatabaseInsertAndPersist() {
        // To separate the testing from the production database, a different `dbName` argument is passed.
        let db = DatabaseController(dbName: "InsertAndPersist.sqlite")

        // Test Pokemon and Team table insertions.
        XCTAssertTrue(db.insertPokemon(pokemon1))
        XCTAssertTrue(db.insertPokemon(pokemon2))
        XCTAssertTrue(db.insertTeam(team1))
        XCTAssertTrue(db.insertTeam(team2))

        // Now, test that the data can be recovered.
        let allPokemon = db.selectAllPokemon()
        let allTeams = db.selectAllTeams()

        // The recovered data must match the original dummy data.
        XCTAssertEqual(allPokemon, [pokemon1, pokemon2])
        XCTAssertEqual(allTeams, [team1, team2])

        // The complete deletion commands must be successful.
        XCTAssertTrue(db.deleteAllPokemon())
        XCTAssertTrue(db.deleteAllTeams())

        // There should be no more Pokemon or teams in the database at the end.
        XCTAssertEqual(db.selectAllPokemon(), [])
        XCTAssertEqual(db.selectAllTeams(), [])
    }

    /// This function tests whether the database will refuse to insert a new row
    /// when the new data clashes with an existing primary key.
    func testInvalidPrimaryKeyRejection() {
        // To separate the testing from the production database, a different `dbName` argument is passed.
        let db = DatabaseController(dbName: "PrimaryKeyRejection.sqlite")

        // Sanity check: the clashing values are not the same in value.
        XCTAssertNotEqual(pokemon1, newPokemon1)
        XCTAssertNotEqual(pokemon2, newPokemon2)
        XCTAssertNotEqual(team1, newTeam1)
        XCTAssertNotEqual(team2, newTeam2)

        // Regular non-clashing insertions should work normally.
        XCTAssertTrue(db.insertPokemon(pokemon1))
        XCTAssertTrue(db.insertPokemon(pokemon2))
        XCTAssertTrue(db.insertTeam(team1))
        XCTAssertTrue(db.insertTeam(team2))

        // Inserting clashing instances (different values but same primary key) should fail.
        XCTAssertFalse(db.insertPokemon(newPokemon1))
        XCTAssertFalse(db.insertPokemon(newPokemon2))
        XCTAssertFalse(db.insertTeam(newTeam1))
        XCTAssertFalse(db.insertTeam(newTeam2))

        // Inserting the exact same instances again should fail since it also clashes primary key.
        XCTAssertFalse(db.insertPokemon(pokemon1))
        XCTAssertFalse(db.insertPokemon(pokemon2))
        XCTAssertFalse(db.insertTeam(team1))
        XCTAssertFalse(db.insertTeam(team2))

        // After all this, there should still remain just two Pokemon and two Teams, with unchanged values.
        XCTAssertEqual(db.selectAllPokemon(), [pokemon1, pokemon2])
        XCTAssertEqual(db.selectAllTeams(), [team1, team2])

        // Finally, complete deletion commands must be also successful.
        XCTAssertTrue(db.deleteAllPokemon())
        XCTAssertTrue(db.deleteAllTeams())
    }

    /// This function tests whether a new Pokemon or Team instance can be used to update
    /// the row corresponding to its primary key in the database.
    func testDatabaseUpdate() {
        // To separate the testing from the production database, a different `dbName` argument is passed.
        let db = DatabaseController(dbName: "DatabaseUpdate.sqlite")

        // Regular insertions should work normally.
        XCTAssertTrue(db.insertPokemon(pokemon1))
        XCTAssertTrue(db.insertPokemon(pokemon2))
        XCTAssertTrue(db.insertTeam(team1))
        XCTAssertTrue(db.insertTeam(team2))

        // Check for persistence and recoverability.
        XCTAssertEqual(db.selectAllPokemon(), [pokemon1, pokemon2])
        XCTAssertEqual(db.selectAllTeams(), [team1, team2])

        // All the updates should work since they match primary keys.
        XCTAssertTrue(db.updatePokemon(newPokemon1))
        XCTAssertTrue(db.updatePokemon(newPokemon2))
        XCTAssertTrue(db.updateTeam(newTeam1))
        XCTAssertTrue(db.updateTeam(newTeam2))

        // Now, check that all the rows match the new values passed through `updatePokemon` and `updateTeam`.
        XCTAssertEqual(db.selectAllPokemon(), [newPokemon1, newPokemon2])
        XCTAssertEqual(db.selectAllTeams(), [newTeam1, newTeam2])

        // Finally, complete deletion commands must be also successful.
        XCTAssertTrue(db.deleteAllPokemon())
        XCTAssertTrue(db.deleteAllTeams())
    }

    /// This function tests whether deletion by a certain primary key works correctly in the database.
    func testDatabaseDelete() {
        // To separate the testing from the production database, a different `dbName` argument is passed.
        let db = DatabaseController(dbName: "DatabaseDelete.sqlite")

        // Regular insertions should work normally.
        XCTAssertTrue(db.insertPokemon(pokemon1))
        XCTAssertTrue(db.insertPokemon(pokemon2))
        XCTAssertTrue(db.insertTeam(team1))
        XCTAssertTrue(db.insertTeam(team2))

        // Check for persistence and recoverability.
        XCTAssertEqual(db.selectAllPokemon(), [pokemon1, pokemon2])
        XCTAssertEqual(db.selectAllTeams(), [team1, team2])

        // Since the primary key being passed to each call here matches an entry in the respective tables,
        // these individual deletion operations must work.
        XCTAssertTrue(db.deletePokemon(by: pokemon1.id))
        XCTAssertTrue(db.deleteTeam(by: team2.id))

        // Now, after the above removals, there should be only one entry in each table
        // corresponding to the elements yet to be deleted.
        XCTAssertEqual(db.selectAllPokemon(), [pokemon2])
        XCTAssertEqual(db.selectAllTeams(), [team1])

        // Finally, we remove the remaining entries.
        XCTAssertTrue(db.deletePokemon(by: pokemon2.id))
        XCTAssertTrue(db.deleteTeam(by: team1.id))

        // Both tables should now be empty.
        XCTAssertTrue(db.selectAllPokemon()?.isEmpty ?? false)
        XCTAssertTrue(db.selectAllTeams()?.isEmpty ?? false)
    }

    /// This function validates the functionality of the `BattleDataFetcher` struct,
    /// which is used for fetching information like ability lists, movesets, base stats, and typing
    /// to be used in Pokémon damage calculation.
    func testBattleDataFetching() async {
        // First, we initialise the resource that fetches battle-related Pokemon data for a given Pokemon.
        let battleDataFetcher = BattleDataFetcher()

        // Here, we test Pokemon that we know to exist:
        // - There are at least three Pokemon in existence,
        // - The original generation consisted of 151,
        // - There are currently 1025 unique Pokemon species (as of Generation IX),
        // - And as per the convention of PokeAPI, special forms start from index 10001.
        let knownValidApiNumbers = [1, 2, 3, 151, 1025, 10001, 10002]

        for number in knownValidApiNumbers {
            let fetchedData = await battleDataFetcher.fetch(number)
            // The API call must be successful. If not, either the indices are wrong or the JSON parsing is wrong.
            XCTAssertNotNil(fetchedData)
        }
    }

    /// This function validates the functionality of the `PokemonNamesFetcher` struct through the
    /// wrapper of the `PokemonNamesViewModel` class. This is crucial for ensuring that Pokémon names
    /// can be rapidly converted into indices that correspond to the PokéAPI internal numbering.
    /// This functionality is important for quick fetching of sprites through their image repository.
    func testPokemonNamesFetching() async {
        let pokemonNamesVM = PokemonNamesViewModel()

        // Upon initialisation, no data will be loaded yet.
        XCTAssertTrue(pokemonNamesVM.filteredResults.isEmpty)

        // Now, the data is loaded.
        await pokemonNamesVM.loadNames()
        // The data should now no longer be empty.
        XCTAssertFalse(pokemonNamesVM.filteredResults.isEmpty)

        // We test fetching the names of known Pokemon with known API IDs to ensure the order is retrieved correctly.
        let knownPairs = [
            1: "bulbasaur",
            2: "ivysaur",
            3: "venusaur",
            151: "mew",
            493: "arceus",
            1025: "pecharunt",
            10001: "deoxys-attack",
            10155: "necrozma-dusk",
            10194: "calyrex-shadow"
        ]

        for (key, value) in knownPairs {
            // For each case, we test that the retrieved name matching what we expect from the given number.
            XCTAssertEqual(pokemonNamesVM.getName(apiId: key), value)
        }
    }

    /// This function validates the functionality of the `ItemsViewModel`,
    /// testing that the API call does not fail and data is loaded properly.
    func testItemFetching() async {
        let itemsVM = ItemsViewModel()

        // Upon initialisation, no data will be loaded yet.
        XCTAssertTrue(itemsVM.filteredResults.isEmpty)

        // Now, the data is loaded.
        await itemsVM.loadItems()
        // The data should now no longer be empty.
        XCTAssertFalse(itemsVM.filteredResults.isEmpty)

        // By default, PokeAPI pagination calls will limit results to 20 items.
        // `loadItems` should load all items, not just 20.
        XCTAssertGreaterThan(itemsVM.filteredResults.count, 20)
    }

    /// This function tests that the `getUniqueId` function in both `Pokemon` and `Team` work as intended,
    /// incrementing an internal counter at each call that causes unique numbers to be generated each call.
    func testAutomaticKeyGeneration() {
        // Each batch of testing in this function will conduct this many iterations.
        let testingStepNumber = 10

        // To start off, set the internal counter to the original value 1.
        Pokemon.resetIdCounter(to: 1)
        Team.resetIdCounter(to: 1)

        // First batch of testing: `Pokemon` and `Team` generate new IDs at the same rate (once per iteration).
        for step in 1...testingStepNumber {
            let newPokemonID = Pokemon.getUniqueId()
            let newTeamID = Team.getUniqueId()
            // Since the counting starts from one, the IDs generated by each type
            // should be the same as the 1-based iteration number.
            XCTAssertEqual(newPokemonID, step)
            XCTAssertEqual(newTeamID, step)
        }

        // Reset the internal counter to the original value 1.
        Pokemon.resetIdCounter(to: 1)
        Team.resetIdCounter(to: 1)

        // Second batch of testing: `Pokemon` is queried twice more than `Team`.
        for step in 1...testingStepNumber {
            let newPokemonID1 = Pokemon.getUniqueId()
            let newPokemonID2 = Pokemon.getUniqueId()
            let newTeamID = Team.getUniqueId()
            // The `Team` ID is generated in tandem with `step`,
            // but the `Pokemon` IDs take up two numbers at each step instead.
            XCTAssertEqual(newPokemonID1, 2 * step - 1)
            XCTAssertEqual(newPokemonID2, 2 * step)
            XCTAssertEqual(newTeamID, step)
        }

        // Reset the internal counter to the original value 1.
        Pokemon.resetIdCounter(to: 1)
        Team.resetIdCounter(to: 1)

        // Third batch of testing: `Team` is queried twice more than `Pokemon`.
        for step in 1...testingStepNumber {
            let newPokemonID = Pokemon.getUniqueId()
            let newTeamID1 = Team.getUniqueId()
            let newTeamID2 = Team.getUniqueId()
            // The `Pokemon` ID is generated in tandem with `step`,
            // but the `Team` IDs take up two numbers at each step instead.
            XCTAssertEqual(newPokemonID, step)
            XCTAssertEqual(newTeamID1, 2 * step - 1)
            XCTAssertEqual(newTeamID2, 2 * step)
        }

        // Reset the internal counter to the original value 1 once again to reset global state.
        Pokemon.resetIdCounter(to: 1)
        Team.resetIdCounter(to: 1)
    }

    /// This function tests that the `TeamReaderViewModel` class is able to read valid teams
    /// from the current format (Pokémon Scarlet and Violet).
    /// Tricky edge cases (such as mismatches between common PokéPaste convention and PokéAPi) are also included.
    func testTeamReader() async {
        // Sample data is initialised with a test team string (importable via the Share Extension).
        // Cases such as nicknames, genders, nicknames and genders,
        // and mismatched conventions (e.g., "As One (Spectrier)" and "Ogerpon-Cornerstone") are covered.
        let teamString = """
        Nickname 1 (Calyrex-Shadow) @ Focus Sash  
        Ability: As One (Spectrier)  
        Level: 50  
        Tera Type: Ghost  
        EVs: 4 HP / 252 SpA / 252 Spe  
        Timid Nature  
        - Astral Barrage  
        - Psychic  
        - Encore  
        - Protect  

        Zamazenta-Crowned @ Rusted Shield  
        Ability: Dauntless Shield  
        Level: 50  
        Tera Type: Dragon  
        EVs: 204 HP / 4 Atk / 156 Def / 20 SpD / 124 Spe  
        Impish Nature  
        - Body Press  
        - Behemoth Bash  
        - Wide Guard  
        - Protect  

        Chien-Pao @ Assault Vest  
        Ability: Sword of Ruin  
        Level: 50  
        Tera Type: Ghost  
        EVs: 252 HP / 4 Atk / 36 Def / 68 SpD / 148 Spe  
        Jolly Nature  
        - Ice Spinner  
        - Sucker Punch  
        - Ice Shard  
        - Ruination  

        Tricky (Nickname) (Dragonite) (M) @ Choice Band  
        Ability: Inner Focus  
        Level: 50  
        Tera Type: Normal  
        EVs: 180 HP / 252 Atk / 4 Def / 4 SpD / 68 Spe  
        Adamant Nature  
        - Extreme Speed  
        - Outrage  
        - Low Kick  
        - Aqua Jet  

        Regular (Amoonguss) @ Rocky Helmet  
        Ability: Regenerator  
        Level: 50  
        Tera Type: Fire  
        EVs: 236 HP / 180 Def / 92 SpD  
        Bold Nature  
        IVs: 0 Atk / 27 Spe  
        - Sludge Bomb  
        - Spore  
        - Rage Powder  
        - Protect  

        Ogerpon-Cornerstone @ Cornerstone Mask  
        Ability: Sturdy  
        Level: 50  
        Tera Type: Rock  
        EVs: 28 HP / 76 Atk / 148 Def / 4 SpD / 252 Spe  
        Adamant Nature  
        - Ivy Cudgel  
        - Power Whip  
        - Follow Me  
        - Spiky Shield  
        """

        // The expected in-code structure of the above representation is written here.
        let correctTeam = [
            Pokemon(
                id: 1,
                pokemonNumber: 10194,
                item: "focus-sash",
                level: 50,
                ability: "as-one-spectrier",
                effortValues: PokemonStats(
                    hp: 4,
                    attack: 0,
                    defense: 0,
                    specialAttack: 252,
                    specialDefense: 0,
                    speed: 252),
                nature: "Timid",
                moves: ["astral-barrage", "psychic", "encore", "protect"]),
            Pokemon(
                id: 2,
                pokemonNumber: 10189,
                item: "rusted-shield",
                level: 50,
                ability: "dauntless-shield",
                effortValues: PokemonStats(
                    hp: 204,
                    attack: 4,
                    defense: 156,
                    specialAttack: 0,
                    specialDefense: 20,
                    speed: 124),
                nature: "Impish",
                moves: ["body-press", "behemoth-bash", "wide-guard", "protect"]),
            Pokemon(
                id: 3,
                pokemonNumber: 1002,
                item: "assault-vest",
                level: 50,
                ability: "sword-of-ruin",
                effortValues: PokemonStats(
                    hp: 252,
                    attack: 4,
                    defense: 36,
                    specialAttack: 0,
                    specialDefense: 68,
                    speed: 148),
                nature: "Jolly",
                moves: ["ice-spinner", "sucker-punch", "ice-shard", "ruination"]),
            Pokemon(
                id: 4,
                pokemonNumber: 149,
                item: "choice-band",
                level: 50,
                ability: "inner-focus",
                effortValues: PokemonStats(
                    hp: 180,
                    attack: 252,
                    defense: 4,
                    specialAttack: 0,
                    specialDefense: 4,
                    speed: 68),
                nature: "Adamant",
                moves: ["extreme-speed", "outrage", "low-kick", "aqua-jet"]),
            Pokemon(
                id: 5,
                pokemonNumber: 591,
                item: "rocky-helmet",
                level: 50,
                ability: "regenerator",
                effortValues: PokemonStats(
                    hp: 236,
                    attack: 0,
                    defense: 180,
                    specialAttack: 0,
                    specialDefense: 92,
                    speed: 0),
                nature: "Bold",
                moves: ["sludge-bomb", "spore", "rage-powder", "protect"]),
            Pokemon(
                id: 6,
                pokemonNumber: 10275,
                item: "cornerstone-mask",
                level: 50,
                ability: "sturdy",
                effortValues: PokemonStats(
                    hp: 28,
                    attack: 76,
                    defense: 148,
                    specialAttack: 0,
                    specialDefense: 4,
                    speed: 252),
                nature: "Adamant",
                moves: ["ivy-cudgel", "power-whip", "follow-me", "spiky-shield"])
        ]

        // We initialise the `TeamReaderViewModel` instance that carries out the conversion logic.
        let teamReader = TeamReaderViewModel()
        // It requires the list of all Pokémon names and matching API indices.
        let namesVM = PokemonNamesViewModel()
        await namesVM.loadNames()

        // First, we check that the created entry list has the same length as the expected one.
        let entries = teamReader.readTeam(teamString)
        XCTAssertEqual(entries.count, correctTeam.count)

        // Then, we check that each element matches the expected corresponding item in the `correctTeam` array.
        for (id, entry) in entries.enumerated() {
            let newPokemon = teamReader.newValidPokemon(from: entry, nameData: namesVM.filteredResults, id: id + 1)
            XCTAssertEqual(newPokemon, correctTeam[id])
        }
    }
}
