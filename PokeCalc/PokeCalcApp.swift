//
//  PokeCalcApp.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI

@main
struct PokeCalcApp: App {
    @State var database = DatabaseViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(database)
        }
    }
}
