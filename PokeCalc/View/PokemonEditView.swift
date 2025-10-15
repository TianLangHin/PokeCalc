//
//  PokemonEditView.swift
//  PokeCalc
//
//  Created by Dương Anh Trần on 15/10/2025.
//

import Foundation
import SwiftUI

struct PokemonEditView: View {
    @State var pokeID: Int
    @EnvironmentObject var database: DatabaseViewModel
    @State var pokemonSpecies: String
    
    var pokemon: Pokemon? {
        database.pokemon.first(where: { $0.id == pokeID })
    }
    
    
    var body: some View {
        NavigationStack {
            let imageurl = pokemon.map { pokemon in
                let itemName = pokemon.item.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: "'", with: "")
                return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(itemName).png"
            } ?? ""
            
            Text("**Pokemon:** \(pokemonSpecies), **ID:** \(pokeID)")
            HStack {
                AsyncImage(url: URL(string: imageurl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                    case .failure:
                        Image("decamark")
                    @unknown default:
                        Image("decamark")
                    }
                }
                
                NavigationLink {
                    ItemLookupView(pokeID: pokeID, itemTF: .constant(""))
                        .environmentObject(database)
                } label: {
                    Text("item: \((pokemon?.item ?? "None").readableFormat())")
                }
            }
            Text("level: \(pokemon?.level ?? 0)")
            Text("ability: \(pokemon?.ability ?? "No ability")")
            Text("nature: \(pokemon?.nature ?? "No personality")")
            
            // This is to work with preset team for now
            Text("move 1: \(pokemon?.getMove(at: 0) ?? "None")")
            Text("move 2: \(pokemon?.getMove(at: 1) ?? "None")")
            Text("move 3: \(pokemon?.getMove(at: 2) ?? "None")")
            Text("move 4: \(pokemon?.getMove(at: 3) ?? "None")")
            
            VStack {
                Text("hp: \(pokemon?.effortValues.hp ?? 0)")
                Text("atk: \(pokemon?.effortValues.attack ?? 0)")
                Text("spatk: \(pokemon?.effortValues.specialAttack ?? 0)")
                Text("spdef: \(pokemon?.effortValues.specialDefense ?? 0)")
                Text("speed: \(pokemon?.effortValues.speed ?? 0)")
                Text("def: \(pokemon?.effortValues.defense ?? 0)")
            }
        }
    }
}
