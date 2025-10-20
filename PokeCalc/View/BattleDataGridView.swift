//
//  BattleDataGridView.swift
//  PokeCalc
//
//  Created by Bella on 20/10/2025.
//

import SwiftUI

struct BattleDataGridView: View {
    let stats: PokemonStats
    
    var body: some View {
        Grid {
            GridRow {
                Text("HP")
                    .font(.headline)
                Text("Atk")
                    .font(.headline)
                Text("Def")
                    .font(.headline)
            }
            
            GridRow {
                Text("\(stats.hp)")
                Text("\(stats.attack)")
                Text("\(stats.defense)")
            }
            .padding(.bottom, 10)
            
            GridRow {
                Text("SpA")
                    .font(.headline)
                Text("SpD")
                    .font(.headline)
                Text("Spe")
                    .font(.headline)
            }
            
            GridRow {
                Text("\(stats.specialAttack)")
                Text("\(stats.specialDefense)")
                Text("\(stats.speed)")
            }
        }
        .padding()
        .overlay(AnyView(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)))
    }
}
