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
                value = min(max(value, 0), 252)
            }
        
        VStack(spacing: 10) {
            Button {
                value = min(max(value+4, 0), 252)
            } label: {
                Image(systemName: "chevron.up")
            }
            
            Button {
                value = min(max(value-4, 0), 252)
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
