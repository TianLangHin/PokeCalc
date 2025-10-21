//
//  DatabaseController.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import Foundation
import SQLite3

/// This is the main resource that manages the persistent storage of Pokemon and Teams in the app.
/// It contains both a Pokemon and a Teams table, with each row in the Teams table carrying
/// foreign key references to the Pokemon table. This allows maximimal flexibility and a clear
/// demarcation of logic between Pokemon within a team and an actual Team on its own.
/// The persistent storage is achieved using a SQLite database.
///
/// All the functions implemented in this class act as wrappers to the SQL query interface,
/// with the raw SQL query strings being declared only within these functions.
/// This abstracts away the SQLite-specific logic from other parts of the app.
///
/// Additionally, since the SQL commands are fallible, the functions that return values
/// will always return an optional, where a `nil` indicates query failure.
/// Meanwhile, if a query does not typically return a value, its wrapping function will return
/// a Boolean, where a returned `true` indicates success and `false` indicates query failure.
class DatabaseController {
    // This database controller can be customised to work on a specific SQLite file,
    // hence the `dbName` can be passed as an argument to the initialiser.
    var db: OpaquePointer?
    let dbName: String

    // The names of the Pokemon and Teams tables are initialised here for easier maintainability
    // (e.g., in case the convention needs to change later).
    let pokemonTable = "Pokemon"
    let teamsTable = "Teams"

    // This resource ensures that the string format stored in the SQLite database
    // is compatible and interchangeable with that of Swift's memory representation.
    let SQLITE_TRANZIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

    // This indicator is used for debugging purposes only,
    // to tell whether the database initialisation was successful.
    var success: Bool

    init(dbName: String = "PokeCalc.sqlite") {
        // First, the database's filename is set here.
        // `success` is also set to `false` first, so any early returns indicate failure.
        // At the end of the initialiser, `success` will be set to `true`.
        self.dbName = dbName
        self.success = false

        // A file path to a persistent location accessible by the App Group is initialised.
        let dbFileUrl = FileManager()
            .containerURL(forSecurityApplicationGroupIdentifier: "group.pokecalc2")?
            .appendingPathComponent(dbName)
        guard let dbFilePath = dbFileUrl?.path else {
            return
        }
        // Then, a SQLite3 connection is opened to this path, creating the entry for the database.
        guard sqlite3_open(dbFilePath, &db) == SQLITE_OK else {
            return
        }

        // Creation of the first table in the schema: the `Pokemon` table contains
        // all the Pokemon sets that the user has made thus far.
        let createPokemonTable = """
        CREATE TABLE IF NOT EXISTS \(pokemonTable) (
            PokemonID INTEGER PRIMARY KEY,
            PokemonNumber INTEGER,
            Item TEXT,
            Level INTEGER,
            Ability TEXT,
            EV_HP INTEGER, EV_Atk INTEGER, EV_Def INTEGER, EV_SpA INTEGER, EV_SpD INTEGER, EV_Spe INTEGER,
            Nature TEXT,
            Move1 TEXT, Move2 TEXT, Move3 TEXT, Move4 TEXT
        );
        """
        // To create the `Pokemon` table, the SQL statement is prepared (from its string representation),
        // then executed in a single step, and then finalised to free resources for future queries.
        var initPokemonStmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, createPokemonTable, -1, &initPokemonStmt, nil) == SQLITE_OK else {
            return
        }
        guard sqlite3_step(initPokemonStmt) == SQLITE_DONE else {
            return
        }
        sqlite3_finalize(initPokemonStmt)

        // Creation of the second table in the schema: the `Teams` table contains all the teams,
        // and each team can reference a maximum of 6 Pokemon in the `Pokemon` table.
        let createTeamsTable = """
        CREATE TABLE IF NOT EXISTS \(teamsTable) (
            TeamID INTEGER NOT NULL PRIMARY KEY,
            TeamName TEXT NOT NULL,
            IsFavourite BOOL NOT NULL,
            Pokemon1 INTEGER NULL, Pokemon2 INTEGER NULL, Pokemon3 INTEGER NULL,
            Pokemon4 INTEGER NULL, Pokemon5 INTEGER NULL, Pokemon6 INTEGER NULL,
            FOREIGN KEY(Pokemon1) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL,
            FOREIGN KEY(Pokemon2) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL,
            FOREIGN KEY(Pokemon3) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL,
            FOREIGN KEY(Pokemon4) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL,
            FOREIGN KEY(Pokemon5) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL,
            FOREIGN KEY(Pokemon6) REFERENCES \(pokemonTable)(PokemonID) ON DELETE SET NULL
        );
        """
        // To create the `Teams` table, the SQL statement is prepared (from its string representation),
        // then executed in a single step, and then finalised to free resources for future queries.
        var initTablesStmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, createTeamsTable, -1, &initTablesStmt, nil) == SQLITE_OK else {
            return
        }
        guard sqlite3_step(initTablesStmt) == SQLITE_DONE else {
            return
        }
        sqlite3_finalize(initTablesStmt)

        // If all the above statements were executed without early returns,
        // then the initialisation was successful.
        self.success = true
    }

    /// This function fetches all the Pokemon that exist in the `Pokemon` table.
    /// If the SQL query fails, a `nil` is returned to signal failure.
    func selectAllPokemon() -> [Pokemon]? {
        // The SQL query is a simple SELECT statement.
        let selectString = "SELECT * FROM \(pokemonTable);"
        var pokemonList: [Pokemon] = []

        var stmt: OpaquePointer? = nil
        // If the query itself is faulty, preparing it will immediately fail.
        guard sqlite3_prepare_v2(db, selectString, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            // At each step of the SQL query's execution, the retrieved values are
            // binded to variables usable in the internal `Pokemon` struct representation.
            let id = Int(sqlite3_column_int64(stmt, 0))
            let number = Int(sqlite3_column_int64(stmt, 1))
            let item = String(cString: sqlite3_column_text(stmt, 2))
            let level = Int(sqlite3_column_int64(stmt, 3))
            let ability = String(cString: sqlite3_column_text(stmt, 4))
            let hpEV = Int(sqlite3_column_int64(stmt, 5))
            let atkEV = Int(sqlite3_column_int64(stmt, 6))
            let defEV = Int(sqlite3_column_int64(stmt, 7))
            let spaEV = Int(sqlite3_column_int64(stmt, 8))
            let spdEV = Int(sqlite3_column_int64(stmt, 9))
            let speEV = Int(sqlite3_column_int64(stmt, 10))
            let nature = String(cString: sqlite3_column_text(stmt, 11))
            // The only slightly differing convention is the use of an array
            // to store the Pokemon's moveset in the `Pokemon` struct. This is constructed here.
            var moveList: [String] = []
            for colNumber in 12...15 {
                let move = String(cString: sqlite3_column_text(stmt, Int32(colNumber)))
                // The absence of a move in one of the four Pokemon slots is represented as an empty string.
                // Hence, such entries are skipped in the creation of the move array.
                if move != "" {
                    moveList.append(move)
                }
            }

            // Additionally, the extracted values are placed in the `PokemonStats` custom struct
            // used in the `Pokemon` internal representation.
            let statSpread = PokemonStats(
                hp: hpEV, attack: atkEV, defense: defEV,
                specialAttack: spaEV, specialDefense: spdEV, speed: speEV)

            // Finally the `Pokemon` struct is constructed and added to the list.
            let pokemon = Pokemon(
                id: id, pokemonNumber: number, item: item, level: level, ability: ability,
                effortValues: statSpread, nature: nature, moves: moveList)
            pokemonList.append(pokemon)
        }
        // The resources are cleared, and the result is returned.
        sqlite3_finalize(stmt)
        return pokemonList
    }

    /// This function fetches all the Pokemon that exist in the `Team` table.
    /// If the SQL query fails, a `nil` is returned to signal failure.
    func selectAllTeams() -> [Team]? {
        // The SQL query is a simple SELECT statement.
        let selectString = "SELECT * FROM \(teamsTable);"
        var teamList: [Team] = []

        var stmt: OpaquePointer? = nil
        // If the query itself is faulty, preparing it will immediately fail.
        guard sqlite3_prepare_v2(db, selectString, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            // At each step of the SQL query's execution, the retrieved values are
            // binded to variables usable in the internal `Team` struct representation.
            let id = Int(sqlite3_column_int64(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let isFavourite = sqlite3_column_int(stmt, 2) != 0
            // The referenced Pokemon IDs are stored in the `Team` struct using an array,
            // even though they correspond to separate (6) columns in the database.
            var pokemonIDs: [Int] = []
            for colNumber in 3...8 {
                // Any column that has a NULL stored in it represents an empty slot,
                // so this is tested before an attempt is made to append it.
                if sqlite3_column_type(stmt, Int32(colNumber)) != SQLITE_NULL {
                    pokemonIDs.append(Int(sqlite3_column_int64(stmt, Int32(colNumber))))
                }
            }
            // The constructed `Team` instance from the extracted values is appended to the array.
            let team = Team(id: id, name: name, isFavourite: isFavourite, pokemonIDs: pokemonIDs)
            teamList.append(team)
        }
        // The resources are cleared, and the result is returned.
        sqlite3_finalize(stmt)
        return teamList
    }

    /// Inserts a new row into the `Pokemon` table.
    /// To work better with the other parts of the app, a `Pokemon` struct instance is passed in,
    /// and the values are extracted before being passed into the SQL query.
    func insertPokemon(_ pokemon: Pokemon) -> Bool {
        // The `?` parts of the SQL INSERT command allow values to be binded.
        let insertString = """
        INSERT INTO \(pokemonTable) (
            PokemonID, PokemonNumber, Item, Level, Ability,
            EV_HP, EV_Atk, EV_Def, EV_SpA, EV_SpD, EV_Spe,
            Nature, Move1, Move2, Move3, Move4
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        // Firstly, if the command is faulty, the function is unsuccessful.
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, insertString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }

        // The values are unpacked one by one from the struct into the correct column format.
        sqlite3_bind_int64(stmt, 1, Int64(pokemon.id))
        sqlite3_bind_int64(stmt, 2, Int64(pokemon.pokemonNumber))
        sqlite3_bind_text(stmt, 3, pokemon.item, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int64(stmt, 4, Int64(pokemon.level))
        sqlite3_bind_text(stmt, 5, pokemon.ability, -1, SQLITE_TRANZIENT)

        sqlite3_bind_int64(stmt, 6, Int64(pokemon.effortValues.hp))
        sqlite3_bind_int64(stmt, 7, Int64(pokemon.effortValues.attack))
        sqlite3_bind_int64(stmt, 8, Int64(pokemon.effortValues.defense))
        sqlite3_bind_int64(stmt, 9, Int64(pokemon.effortValues.specialAttack))
        sqlite3_bind_int64(stmt, 10, Int64(pokemon.effortValues.specialDefense))
        sqlite3_bind_int64(stmt, 11, Int64(pokemon.effortValues.speed))

        sqlite3_bind_text(stmt, 12, pokemon.nature, -1, SQLITE_TRANZIENT)

        for colNumber in 1...4 {
            sqlite3_bind_text(stmt, Int32(12 + colNumber), pokemon.getMove(at: colNumber - 1), -1, SQLITE_TRANZIENT)
        }

        // Then, the query is executed, finalised, and a `true` value is returned if successful.
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Inserts a new row into the `Team` table.
    /// To work better with the other parts of the app, a `Team` struct instance is passed in,
    /// and the values are extracted before being passed into the SQL query.
    func insertTeam(_ team: Team) -> Bool {
        // The `?` parts of the SQL INSERT command allow values to be binded.
        let insertString = """
        INSERT INTO \(teamsTable) (
            TeamID, TeamName, IsFavourite,
            Pokemon1, Pokemon2, Pokemon3,
            Pokemon4, Pokemon5, Pokemon6
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        // Firstly, if the command is faulty, the function is unsuccessful.
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, insertString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(stmt, 1, Int64(team.id))
        sqlite3_bind_text(stmt, 2, team.name, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int(stmt, 3, team.isFavourite ? 1 : 0)
        // The `Team` may contain less than 6 Pokemon, even though the schema has strictly six columns.
        // In such cases, the empty slots are binded with NULL values instead.
        // This utilises the convenience function `getPokemonID` defined in the `Team` struct.
        for colNumber in 1...6 {
            if let pokemonID = team.getPokemonID(at: colNumber - 1) {
                sqlite3_bind_int(stmt, Int32(3 + colNumber), Int32(pokemonID))
            } else {
                sqlite3_bind_null(stmt, Int32(3 + colNumber))
            }
        }

        // Then, the query is executed, finalised, and a `true` value is returned if successful.
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Updates a particular row of the `Pokemon` table.
    /// To work better with the other parts of the app, a `Pokemon` struct instance is passed in,
    /// which contains the new values of the struct with a matching primary key (in the `id` field).
    /// This allows particular rows of the table to be updated without needing persistent references
    /// in the memory to be passed through various Views, and instead be manipulated purely using value-types.
    func updatePokemon(_ pokemon: Pokemon) -> Bool {
        // The UDPATE statement also needs the values to be binded,
        // with the only difference with the INSERT being that the ID is the last to be binded in the query.
        let updateString = """
        UPDATE \(pokemonTable)
        SET
            PokemonNumber = ?,
            Item = ?,
            Level = ?,
            Ability = ?,
            EV_HP = ?, EV_Atk = ?, EV_Def = ?, EV_SpA = ?, EV_SpD = ?, EV_Spe = ?,
            Nature = ?,
            Move1 = ?, Move2 = ?, Move3 = ?, Move4 = ?
        WHERE PokemonID = ?;
        """

        // Firstly, if the command is faulty, the function is unsuccessful.
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, updateString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        sqlite3_bind_int64(stmt, 1, Int64(pokemon.pokemonNumber))
        sqlite3_bind_text(stmt, 2, pokemon.item, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int64(stmt, 3, Int64(pokemon.level))
        sqlite3_bind_text(stmt, 4, pokemon.ability, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int64(stmt, 5, Int64(pokemon.effortValues.hp))
        sqlite3_bind_int64(stmt, 6, Int64(pokemon.effortValues.attack))
        sqlite3_bind_int64(stmt, 7, Int64(pokemon.effortValues.defense))
        sqlite3_bind_int64(stmt, 8, Int64(pokemon.effortValues.specialAttack))
        sqlite3_bind_int64(stmt, 9, Int64(pokemon.effortValues.specialDefense))
        sqlite3_bind_int64(stmt, 10, Int64(pokemon.effortValues.speed))
        sqlite3_bind_text(stmt, 11, pokemon.nature, -1, SQLITE_TRANZIENT)
        // The convenience function `getMove` returns the blank "" placeholder,
        // which is useful here for empty moves.
        for moveNumber in 1...4 {
            sqlite3_bind_text(stmt, Int32(11 + moveNumber), pokemon.getMove(at: moveNumber - 1), -1, SQLITE_TRANZIENT)
        }
        // The ID is the last element to be binded, as per the order of `?` in the query.
        sqlite3_bind_int64(stmt, 16, Int64(pokemon.id))

        // Then, the query is executed, finalised, and a `true` value is returned if successful.
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Updates a particular row of the `Team` table.
    /// To work better with the other parts of the app, a `Team` struct instance is passed in,
    /// which contains the new values of the struct with a matching primary key (in the `id` field).
    /// This allows particular rows of the table to be updated without needing persistent references
    /// in the memory to be passed through various Views, and instead be manipulated purely using value-types.
    func updateTeam(_ team: Team) -> Bool {
        // The UDPATE statement also needs the values to be binded,
        // with the only difference with the INSERT being that the ID is the last to be binded in the query.
        let updateString = """
        UPDATE \(teamsTable)
        SET
            TeamName = ?, IsFavourite = ?,
            Pokemon1 = ?, Pokemon2 = ?, Pokemon3 = ?,
            Pokemon4 = ?, Pokemon5 = ?, Pokemon6 = ?
        WHERE TeamID = ?;
        """

        // Firstly, if the command is faulty, the function is unsuccessful.
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, updateString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(stmt, 1, team.name, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int(stmt, 2, team.isFavourite ? 1 : 0)
        for pokemonNumber in 1...6 {
            // If there is an empty spot in the list of Pokemon attached to the Team,
            // then a NULL is binded to that position.
            if let pokemonID = team.getPokemonID(at: pokemonNumber - 1) {
                sqlite3_bind_int64(stmt, Int32(2 + pokemonNumber), Int64(pokemonID))
            } else {
                sqlite3_bind_null(stmt, Int32(2 + pokemonNumber))
            }
        }
        // The ID is the last to be binded as per the `?` position.
        sqlite3_bind_int64(stmt, 9, Int64(team.id))
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Deletes a row in the `Pokemon` table based on the primary key.
    func deletePokemon(by id: Int) -> Bool {
        let deleteString = "DELETE FROM \(pokemonTable) WHERE PokemonID = ?;"
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, deleteString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        sqlite3_bind_int64(stmt, 1, Int64(id))
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Deletes a row in the `Team` table based on the primary key.
    func deleteTeam(by id: Int) -> Bool {
        let deleteString = "DELETE FROM \(teamsTable) WHERE TeamID = ?;"
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, deleteString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        sqlite3_bind_int64(stmt, 1, Int64(id))
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Used mostly for debugging purposes: clears all the entries in the entire `Pokemon` table.
    func deleteAllPokemon() -> Bool {
        let deleteString = "DELETE FROM \(pokemonTable);"
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, deleteString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }

    /// Used mostly for debugging purposes: clears all the entries in the entire `Team` table.
    func deleteAllTeams() -> Bool {
        let deleteString = "DELETE FROM \(teamsTable);"
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, deleteString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }
}
