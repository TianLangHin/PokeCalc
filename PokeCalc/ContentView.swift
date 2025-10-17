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

    var body: some View {
        TabView {
            PokemonLookupView(isViewing: false)
                .environmentObject(database)
                .tabItem {
                    Image("ditto")
                    Text("Pokémon")
                }
            NavigationStack {
                TeamsView()
                    .environmentObject(database)
            }
            .tabItem {
                Image("pokemon")
                Text("Teams")
            }
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DatabaseViewModel())
}
