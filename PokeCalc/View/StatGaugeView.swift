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
        .tint(getStatColour())
    }
    
    // These stat colours are taken from the pokepast.es syntax-eviv.css style sheet, which assigns each stat its own colour for visual distinction.
    func getStatColour() -> Color {
        switch self.stat {
        case "HP": return Color(hex: 0xFF0000)
        case "ATK": return Color(hex: 0xF08030)
        case "DEF": return Color(hex: 0xF8D030)
        case "SpATK": return Color(hex: 0x6890F0)
        case "SpDEF": return Color(hex: 0x78C850)
        case "SPE": return Color(hex: 0xF85888)
        default: return Color.gray
        }
    }
}
