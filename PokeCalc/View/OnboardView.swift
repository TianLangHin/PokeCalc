//
//  OnboardView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 20/10/2025.
//


import Foundation
import SwiftUI

/// This view is displayed upon the app's first startup, and also in the last page of the main tab view.
/// It provides a user guide for using the various features of the app.
struct OnboardView: View {
    // This view may need to programmatically dismiss itself, hence this is required.
    @Environment(\.dismiss) var dismiss

    // This view also has different pages,
    // and will display differently depending on whether it is shown in a sheet or not.
    @State var page: Int = 0
    @State var isSheet: Bool = false

    // The selected tab is used as a way to automatically jump back to the first page of the app when dismissed.
    @Binding var selectedTab: Int

    var body: some View {
        // The content of this view is a TabView of its own, but without a visible bar.
        TabView(selection: $page) {
            // There are three pages to this guide,
            // and each have different content being represented by different `index` values.
            ForEach(0..<3) { index in
                VStack {
                    if index == 0 {
                        // First page.
                        Spacer()
                        Text("Hi Trainer! Welcome to PokeCalc.")
                            .font(.title3)
                            .padding()
                            .bold()

                        Text("If this your first time using this app, click on the following prompt to go to the team list and create your first team.")
                        Image("Addpokemonprompt")
                            .resizable()
                            .scaledToFit()
                            .border(Color.black, width: 2)
                            .padding()
                        Image("AddTeam")
                            .resizable()
                            .scaledToFit()
                            .border(Color.black, width: 2)
                            .padding()
                        Text("Now you are equipped with a team 👍, let's start putting in some Pokémon!")
                    } else if index == 1 {
                        // Second page.
                        Spacer()
                        ScrollView {
                            Text("User Guide (Cont.)")
                                .bold()
                                .padding()

                            Text("You can then add your Pokemon in the team by doing the following:")
                            Text("Click on the **+** symbol to start adding Pokémon.")
                            Image("symbol")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)

                            Text("After that, choose a Pokémon from the list of available species:")
                            Image("PokemonList")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)

                            Text("Customise and add your desired setup to your Pokémon. Click on **Add Pokémon**, and... ta-da, new Pokémon added! 🎊")
                            Image("PokemonInfo")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                        }
                    } else if index == 2 {
                        // Third page.
                        Spacer()
                        ScrollView {
                            Text("User Guide (Cont.)")
                                .bold()
                                .padding()

                            Text("After adding the new Pokémon setup into your desired team, you can either go to team to see your Pokémon setups, or go back to **Pokémon** tab and search for setups based on Pokémon species.")
                            Image("PokemonLookup")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)

                            Text("When ready, you can then go to the **Calculator** tab to import your team(s) into a battle simulator that calculate the damage of your pokemon between teams.")
                            Image("Calculator")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)

                            Text("This will give you a better understanding of the Pokémon's characteristics, helping you choosing the best team possible ✅")
                                .padding()
                            Text("That's it! Let's get started!")
                                .bold()
                        }
                    }

                    Spacer()
                    // Below the custom content of each page,
                    // a button is provided to either advance the page or move back to the main app.
                    Button {
                        if page < 2 {
                            page += 1
                        } else {
                            if isSheet {
                                dismiss()
                            } else {
                                selectedTab = 0
                            }
                        }
                    } label: {
                        Text(page < 2 ? "Next" : "Get Started")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle())
    }
}
