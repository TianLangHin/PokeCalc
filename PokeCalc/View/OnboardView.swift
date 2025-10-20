//
//  OnboardView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 20/10/2025.
//


import Foundation
import SwiftUI

struct OnboardView: View {
    @State var page: Int = 0
    @Environment(\.dismiss) var dismiss
    @State var isSheet: Bool = false
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $page){
            ForEach(0..<3) { index in
                VStack {
                    if index == 0 {
                            Spacer()
                            Text("**Hi Trainer! Welcome to PokeCalc**")
                                .font(.title2)
                                .padding()
                            
                            Text("If this is the first time you use the app, click on the following prompt to go to the team list and create your first team.")
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
                            
                            Text("Now you are equipped with a team 👍, let's start putting in some Pokemon!")
                        
                    } else if index == 1 {
                        Spacer()
                        ScrollView {
                            Text("User Guide (Cont)")
                                .bold()
                                .padding()
                            
                            Text("You can then add your Pokemon in the team by doing the following:")
                            Text("Click on the **+** symbol to start adding Pokemon")
                            
                            Image("symbol")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)
                            
                            Text("After that choose a Pokemon from the list of available species:")
                            Image("PokemonList")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)
                            
                            Text("Customise and add your desired setup to your Pokemon. Click on **Add Pokemon**, and...Ta-da, new Pokemon added! 🎊")
                            Image("PokemonInfo")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                        }
                        
                    } else if index == 2 {
                        Spacer()
                        ScrollView {
                            Text("User Guide (Cont)")
                                .bold()
                                .padding()
                            
                            Text("After adding the new Pokemon setup into your desired team, you can either go to team to see your Pokemon setups, or go back to **Pokemon** tab and search for setups based on Pokemon species")
                            Image("PokemonLookup")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)
                            
                            Text("When ready, you can then go to the **Calculator** tab to import your team(s) into a battle simulator that calculate the damage of your pokemon between teams")
                            
                            Image("Calculator")
                                .resizable()
                                .scaledToFit()
                                .border(Color.black, width: 2)
                                .padding()
                                .padding(.bottom, 5)
                            
                            
                            Text("This will give you a better understanding of the Pokemon's characteristics, helping you choosing the best team possible ✅")
                                .padding()
                            
                            Text("That's it! Let's get started!")
                                .bold()
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        if page < 2 {
                            page += 1
                        } else {
                            if isSheet {
                                dismiss()
                            } else {
                                selectedTab = 0
                            }
                        }
                    }) {
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
