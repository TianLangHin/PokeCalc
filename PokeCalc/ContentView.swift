//
//  ContentView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin, Duong Anh Tran, Isabella Watt on 9/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var database: DatabaseViewModel

    @State var alerting = false
    @State var selectedTab: Int = 0
    
    
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    @State private var firstLaunch: Bool = false
    

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PokemonLookupView(selectedTab: $selectedTab)
                    .environmentObject(database)
                    .navigationTitle("Pokémon Lookup")
            }
            .tabItem {
                Image("ditto")
                Text("Pokémon")
            }
            .tag(0)

            NavigationStack {
                TeamsView()
                    .environmentObject(database)
                    .navigationTitle("Teams")
            }
            .tabItem {
                Image("pokemon")
                Text("Teams")
            }
            .tag(1)

            NavigationStack {
                CalculationView()
                    .environmentObject(database)
                    .navigationTitle("Damage Calculation")
            }
            .tabItem {
                Image("battle")
                Text("Calculator")
            }
            .tag(2)
            
            
            OnboardView(isSheet: false, selectedTab: $selectedTab)
            .id(selectedTab == 3 ? "guide-\(UUID())" : "guide-static")
            .tabItem {
                Image("guideIcon")
                Text("Guide")
            }
            .tag(3)
        }
        .onAppear {
            if !hasLaunchedBefore {
                firstLaunch = true
                hasLaunchedBefore = true
            }
        }
        .sheet(isPresented: $firstLaunch) {
            OnboardView(isSheet: true, selectedTab: $selectedTab)
                .presentationDragIndicator(.visible) 
        }

    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseViewModel())
}
