//
//  ContentView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin, Duong Anh Tran, Isabella Watt on 9/10/2025.
//

import SwiftUI

/// This View constitutes the main app page through which the user
/// interacts with all of the app functionalities.
struct ContentView: View {
    // Most child Views will need access to the database,
    // which persistenty stores all the teams and Pokémon sets made by the user.
    @EnvironmentObject var database: DatabaseViewModel

    // This is used to control whether to prompt the user with an app guide
    // during the first time the user launches the app.
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    @State private var firstLaunch: Bool = false

    // All the app's functionalities are accessible through a TabView,
    // and can be navigated to outside the bottom tab.
    // Hence, a state is used to keep track of the selected tab.
    @State var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // The first functionality is Pokémon lookup.
            // For a given Pokémon, it will list all the existing instances
            // in any team currently stored.
            NavigationStack {
                // The view is wrapped in a NavigationStack
                // to enable the `searchable` modifier.
                PokemonLookupView(selectedTab: $selectedTab)
                    .environmentObject(database)
                    .navigationTitle("Pokémon Lookup")
            }
            .tabItem {
                Image("ditto")
                Text("Pokémon")
            }
            .tag(0)

            // The second functionality is making Pokémon teams.
            // They can be added, edited, and deleted.
            NavigationStack {
                // The view is wrapped in a NavigationStack
                // to enable the `searchable` modifier.
                TeamsView()
                    .environmentObject(database)
                    .navigationTitle("Teams")
            }
            .tabItem {
                Image("pokemon")
                Text("Teams")
            }
            .tag(1)

            // The third functionality is calculating Pokémon battle damage.
            // This is the main purpose of the app, allowing the user to
            // compare two teams head to head while visualising the amount
            // of damage done by each Pokémon in the teams.
            NavigationStack {
                // The `.id(UUID())` modifier forces the View to re-render
                // each time the tab changes,
                // so that modifications to the persistently stored teams
                // will always be display updates upon loading.
                CalculationView()
                    .environmentObject(database)
                    .navigationTitle("Damage Calculation")
                    .id(UUID())
            }
            .tabItem {
                Image("battle")
                Text("Calculator")
            }
            .tag(2)

            // The OnboardView keeps the app guide accessible to the user
            // even after the first launch, in case it is needed.
            OnboardView(isSheet: false, selectedTab: $selectedTab)
                .id(selectedTab == 3 ? "guide-\(UUID())" : "guide-static")
                .tabItem {
                    Image("guideIcon")
                    Text("Guide")
                }
                .tag(3)
        }
        .onAppear {
            // The OnboardView appears immediately if this is the first launch.
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
