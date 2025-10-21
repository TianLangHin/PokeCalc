//
//  StatGaugeView.swift
//  PokeCalc
//
//  Created by Bella on 17/10/2025.
//

import SwiftUI

struct StatGaugeView: View {
    @State var stat: String
    @Binding var value: Int

    var body: some View {
        Text("\(stat):")
            .font(.headline)
            .bold()
        
        TextField("Enter EV Value...", value: $value, format: .number)
            .frame(width: 80)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .onChange(of: value) {
                value = Pokemon.clipEV(value: value)
            }
        
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
