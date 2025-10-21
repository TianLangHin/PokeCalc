//
//  BattleDataGridView.swift
//  PokeCalc
//
//  Created by Bella on 20/10/2025.
//

import SwiftUI

/// This View is intended as a compact UI element to display the combat stats of a Pokemon inside CalculationView.
struct BattleDataGridView: View {
    // The PokemonStats struct is passed as a parameter rather than a State so that
    // this View will re-render when the values in the parent View change.
    let stats: PokemonStats

    var body: some View {
        Grid {
            // Since there are six stats, to fit compactly in the screen, a 2x3 conceptual grid is used,
            // and since the numeric values and stat labels are separate, this results in 4 rows and 3 columns.
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
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
        // An overlay of a rounded rectangle separates the element nicely from the other parts of the parent View.
    }
}
