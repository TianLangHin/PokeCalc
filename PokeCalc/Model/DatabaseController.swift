//
//  DatabaseController.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

import Foundation
import SQLite3

class DatabaseController {
    var db: OpaquePointer?
    let dbName: String

    let pokemonTable = "Pokemon"
    let teamsTable = "Teams"

    let SQLITE_TRANZIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

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

    func selectAllPokemon() -> [Pokemon]? {
        let selectString = "SELECT * FROM \(pokemonTable);"
        var pokemonList: [Pokemon] = []

        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, selectString, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int64(stmt, 0))
            let number = Int(sqlite3_column_int64(stmt, 1))
            let item = String(cString: sqlite3_column_text(stmt, 2))
            let level = Int(sqlite3_column_int64(stmt, 3))
            let hpEV = Int(sqlite3_column_int64(stmt, 4))
            let atkEV = Int(sqlite3_column_int64(stmt, 5))
            let defEV = Int(sqlite3_column_int64(stmt, 6))
            let spaEV = Int(sqlite3_column_int64(stmt, 7))
            let spdEV = Int(sqlite3_column_int64(stmt, 8))
            let speEV = Int(sqlite3_column_int64(stmt, 9))
            let nature = String(cString: sqlite3_column_text(stmt, 10))
            var moveList: [String] = []
            for colNumber in 11...14 {
                let move = String(cString: sqlite3_column_text(stmt, Int32(colNumber)))
                if move != "" {
                    moveList.append(move)
                }
            }

            let statSpread = PokemonStats(
                hp: hpEV, attack: atkEV, defense: defEV,
                specialAttack: spaEV, specialDefense: spdEV, speed: speEV)

            let pokemon = Pokemon(
                id: id, pokemonNumber: number, item: item, level: level,
                effortValues: statSpread, nature: nature, moves: moveList)
            pokemonList.append(pokemon)
        }
        sqlite3_finalize(stmt)
        return pokemonList
    }

    func selectAllTeams() -> [Team]? {
        let selectString = "SELECT * FROM \(teamsTable);"
        var teamList: [Team] = []

        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, selectString, -1, &stmt, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int64(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let isFavourite = sqlite3_column_int(stmt, 2) != 0
            var pokemonIDs: [Int] = []
            for colNumber in 3...8 {
                if sqlite3_column_type(stmt, Int32(colNumber)) != SQLITE_NULL {
                    pokemonIDs.append(Int(sqlite3_column_int64(stmt, Int32(colNumber))))
                }
            }
            let team = Team(id: id, name: name, isFavourite: isFavourite, pokemonIDs: pokemonIDs)
            teamList.append(team)
        }
        sqlite3_finalize(stmt)
        return teamList
    }

    func insertPokemon(_ pokemon: Pokemon) -> Bool {
        let insertString = """
        INSERT INTO \(pokemonTable) (
            PokemonID, PokemonNumber, Item, Level,
            EV_HP, EV_Atk, EV_Def, EV_SpA, EV_SpD, EV_Spe,
            Nature, Move1, Move2, Move3, Move4
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, insertString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(stmt, 1, Int64(pokemon.id))
        sqlite3_bind_int64(stmt, 2, Int64(pokemon.pokemonNumber))
        sqlite3_bind_text(stmt, 3, pokemon.item, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int64(stmt, 4, Int64(pokemon.level))

        sqlite3_bind_int64(stmt, 5, Int64(pokemon.effortValues.hp))
        sqlite3_bind_int64(stmt, 6, Int64(pokemon.effortValues.attack))
        sqlite3_bind_int64(stmt, 7, Int64(pokemon.effortValues.defense))
        sqlite3_bind_int64(stmt, 8, Int64(pokemon.effortValues.specialAttack))
        sqlite3_bind_int64(stmt, 9, Int64(pokemon.effortValues.specialDefense))
        sqlite3_bind_int64(stmt, 10, Int64(pokemon.effortValues.speed))

        sqlite3_bind_text(stmt, 11, pokemon.nature, -1, SQLITE_TRANZIENT)

        for colNumber in 1...4 {
            sqlite3_bind_text(stmt, Int32(11 + colNumber), pokemon.getMove(at: colNumber - 1), -1, SQLITE_TRANZIENT)
        }

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }

        sqlite3_finalize(stmt)
        return true
    }

    func insertTeam(_ team: Team) -> Bool {
        let insertString = """
        INSERT INTO \(teamsTable) (
            TeamID, TeamName, IsFavourite,
            Pokemon1, Pokemon2, Pokemon3,
            Pokemon4, Pokemon5, Pokemon6
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, insertString, -1, &stmt, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(stmt, 1, Int64(team.id))
        sqlite3_bind_text(stmt, 2, team.name, -1, SQLITE_TRANZIENT)
        sqlite3_bind_int(stmt, 3, team.isFavourite ? 1 : 0)
        for colNumber in 1...6 {
            if let pokemonID = team.getPokemonID(at: colNumber - 1) {
                sqlite3_bind_int(stmt, Int32(3 + colNumber), Int32(pokemonID))
            } else {
                sqlite3_bind_null(stmt, Int32(3 + colNumber))
            }
        }

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return false
        }

        sqlite3_finalize(stmt)
        return true
    }

    func deleteAllPokemon() -> Bool {
        let deleteString = "DELETE FROM \(pokemonTable)"
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

    func deleteAllTeams() -> Bool {
        let deleteString = "DELETE FROM \(teamsTable)"
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
