//
//  StatGaugeView.swift
//  PokeCalc
//
//  Created by Bella on 17/10/2025.
//

import SwiftUI

/// This view is meant to be a small UI element that allows the user
/// to customise the effort value of a Pokemon.
struct StatGaugeView: View {
    // This view needs the name of the stat being modified and a binding to update parent view state.
    @State var stat: String
    @Binding var value: Int

    var body: some View {
        // No VStack or HStack is used here since these are all columns of a GridRow.
        Text("\(stat):")
            .font(.headline)
            .bold()

        // The user can enter integer values directly to set the stat value.
        TextField("Enter EV Value...", value: $value, format: .number)
            .frame(width: 80)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .onChange(of: value) {
                value = Pokemon.clipEV(value: value)
            }

        // The stepper increments the stat by 4 points, which is specific to Pokemon logic.
        VStack(spacing: 10) {
            Button {
                value = Pokemon.clipEV(value: value + 4)
            } label: {
                Image(systemName: "chevron.up")
            }
            Button {
                value = Pokemon.clipEV(value: value - 4)
            } label: {
                Image(systemName: "chevron.down")
            }
        }

        // Finally, the gauge visualises how many points have been added relative to the total possible amount.
        Gauge(value: Double(value), in: 0...252) {
            EmptyView()
        } currentValueLabel: {
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("252")
        }
        .tint(Color.getStatColour(stat: stat))
    }
}
