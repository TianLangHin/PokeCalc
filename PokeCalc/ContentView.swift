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
    

    var body: some View {
        TabView(selection: $selectedTab){
            PokemonLookupView(selectedTab: $selectedTab, isViewing: true)
                .environmentObject(database)
                .tabItem {
                    Image("ditto")
                    Text("Pokémon")
                }
                .tag(0)
            
            NavigationStack {
                TeamsView()
                    .environmentObject(database)
            }
            .tabItem {
                Image("pokemon")
                Text("Teams")
            }
            .tag(1)
            
            VStack {
                Text("Successful Initialisation: \(database.dbController.success)")
                Text("Pokémon")
                List {
                    ForEach(database.pokemon, id: \.self) { pokemon in
                        Text("\(pokemon)")
                    }
                }
                Text("Teams")
                List {
                    ForEach(database.teams, id: \.self) { team in
                        Text("\(team)")
                    }
                }
                Button {
                    alerting = !database.clear()
                } label: {
                    Text("Clear")
                }
            }
            .padding()
            .alert("", isPresented: $alerting) {
                Button("Dismiss", role: .cancel) {}
            }
            .tabItem {
                Image(systemName: "info.circle")
                Text("Debug")
            }
            .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseViewModel())
}
