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
}

struct SimpleEntry: TimelineEntry {
    var date: Date
}

/// This View shows the sprite of a Pokemon based on their PokéAPI index.
/// The `0` index is used to retrieve the placeholder image from their repository.
/// The data is fetched synchronously rather than using an AsyncImage since
/// widgets do not refresh on their own, requiring it to be loaded in one go.
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
            // A system globe image is used as a placeholder if this data retrieval fails.
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

/// This is the View which is displayed in the Widget.
/// It takes its data directly from the database,
/// so the Entry is not used to carry any particular data.
struct PokeCalcWidgetEntryView : View {
    var entry: Provider.Entry
    let db = DatabaseController()

    var body: some View {
        VStack {
            // The list of all `Pokemon` instances in the database is used
            // to convert the elements of the `pokemonIDs` array of the
            // chosen display team into actual `Pokemon` structs.
            let pokemonData = db.selectAllPokemon() ?? []
            // If there is a team in the database that can be displayed,
            // the Pokemon of the team are displayed in a 2x3 grid.
            if let team = displayTeam() {
                VStack(alignment: .center) {
                    // First, the team name is shown.
                    Text(team.name)
                        .fontWeight(.bold)
                    // Next, the six Pokemon (with placeholders if empty) are shown.
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
                // If there is no team present, a big placeholder is used
                // to encourage the user to make a team.
                VStack(alignment: .center) {
                    Text("Make a team first!")
                        .fontWeight(.bold)
                    SynchronousImage(number: 0)
                }
            }
        }
    }

    // If the Pokemon referenced by the team at the index `place` is valid
    // and that index exists in the `pokemonIDs` array,
    // then the Pokemon's sprite is displayed. Otherwise, a placeholder is used.
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

    // This determines which team to display.
    // As long as there is at least one team in the database,
    // this will return a `Team`. If there are none, `nil` is returned.
    // The chosen team is the first favourite team,
    // or the first team if there are no favourites.
    func displayTeam() -> Team? {
        let allTeams = db.selectAllTeams()?.sorted(by: { team1, team2 in
            if team1.isFavourite == team2.isFavourite {
                return team1.id < team2.id
            } else {
                return team1.isFavourite
            }
        })
        return allTeams?.first
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
