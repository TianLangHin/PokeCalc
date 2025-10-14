//
//  PokeCalcWidget.swift
//  PokeCalcWidget
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
}

struct SynchronousImage: View {
    @State var number: Int

    var body: some View {
        let imgUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(number).png"
        if let url = URL(string: imgUrl),
           let imageData = try? Data(contentsOf: url),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct PokeCalcWidgetEntryView : View {
    var entry: Provider.Entry
    let db = DatabaseController()

    var body: some View {
        VStack {
            let pokemonData = db.selectAllPokemon() ?? []
            if let team = db.selectAllTeams()?.first {
                VStack(alignment: .center) {
                    Text(team.name)
                        .fontWeight(.bold)
                    Grid() {
                        GridRow {
                            pokemon(pokemonData: pokemonData, team: team, place: 0)
                            pokemon(pokemonData: pokemonData, team: team, place: 1)
                            pokemon(pokemonData: pokemonData, team: team, place: 2)
                        }
                        GridRow {
                            pokemon(pokemonData: pokemonData, team: team, place: 3)
                            pokemon(pokemonData: pokemonData, team: team, place: 4)
                            pokemon(pokemonData: pokemonData, team: team, place: 5)
                        }
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Text("Make a team first!")
                        .fontWeight(.bold)
                    SynchronousImage(number: 0)
                }
            }
        }
    }

    @ViewBuilder
    func pokemon(pokemonData: [Pokemon], team: Team, place: Int) -> some View {
        if team.pokemonIDs.count > place {
            let pokemonID = team.pokemonIDs[place]
            if let pokemon = pokemonData.first(where: { $0.id == pokemonID }) {
                SynchronousImage(number: pokemon.pokemonNumber)
            } else {
                SynchronousImage(number: 0)
            }
        } else {
            SynchronousImage(number: 0)
        }
    }
}

struct PokeCalcWidget: Widget {
    let kind: String = "PokeCalcWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PokeCalcWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

#Preview(as: .systemMedium) {
    PokeCalcWidget()
} timeline: {
    SimpleEntry(date: .now)
}
