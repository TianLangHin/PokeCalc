//
//  TeamReadTestView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 13/10/2025.
//

import SwiftUI

struct TeamReadTestView: View {
    @State var text = ""
    @State var teamReader = TeamReaderViewModel()
    @State var team: [TeamReaderViewModel.PokemonEntry] = []
    var body: some View {
        VStack {
            TextField("Team Text", text: $text, axis: .vertical)
                .lineLimit(10...15)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button {
                    team = teamReader.readTeam(text)
                } label: {
                    Text("Convert")
                }
                Spacer()
                Button {
                    team = []
                } label: {
                    Text("Clear")
                }
            }
            .padding()
            List {
                ForEach($team, id: \.self) { $pokemon in
                    VStack {
                        HStack {
                            Text(pokemon.species)
                            Text(pokemon.nickname ?? "N/A")
                            switch pokemon.gender {
                            case .male:
                                Text("M")
                            case .female:
                                Text("F")
                            case nil:
                                Text("-")
                            }
                            Text(pokemon.item ?? "N/A")
                        }
                        Text("Level \(pokemon.level)")
                        Text(pokemon.ability ?? "N/A")
                        HStack {
                            let ev = pokemon.effortValues
                            Text("\(ev.hp) HP / \(ev.attack) Atk / \(ev.defense) Def / \(ev.specialAttack) SpA / \(ev.specialDefense) SpD / \(ev.speed) Spe")
                        }
                        HStack {
                            let iv = pokemon.individualValues
                            Text("\(iv.hp) HP / \(iv.attack) Atk / \(iv.defense) Def / \(iv.specialAttack) SpA / \(iv.specialDefense) SpD / \(iv.speed) Spe")
                        }
                        Text("Nature: \(pokemon.nature)")
                        ForEach(pokemon.moves, id: \.self) { move in
                            Text(move)
                        }
                        .border(.black)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    TeamReadTestView()
}
