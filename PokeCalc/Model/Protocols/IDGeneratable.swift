//
//  IDGeneratable.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

protocol IDGeneratable {
    static func getUniqueId() -> Int
    static func resetIdCounter(to: Int)
}
