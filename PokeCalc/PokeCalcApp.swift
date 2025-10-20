//
//  PokeCalcApp.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI

@main
struct PokeCalcApp: App {
    // In the main application, the global `DatabaseViewModel` instance
    // is initialiseed so that all Views have access to the persistent storage.
    @State var database = DatabaseViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(database)
        }
    }
}
