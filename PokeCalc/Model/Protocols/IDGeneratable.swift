//
//  IDGeneratable.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

/// This protocol defines the behaviour of classes
/// that generate primary keys for storage in an SQLite database.
protocol IDGeneratable {
    // The class itself must keep some internal counter and return a unique number
    // in each successive call of this function.
    static func getUniqueId() -> Int

    // The internal counter can be reset to either avoid a certain possibly-filled range,
    // or instead to reset it back to a now-empty range.
    static func resetIdCounter(to: Int)
}
