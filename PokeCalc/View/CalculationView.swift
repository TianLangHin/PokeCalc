//
//  CalculationView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 18/10/2025.
//

import SwiftUI

/// This View is one of the main functionalities of the app:
/// calculating the amount of damage a Pokémon would do against another,
/// and comparing teams head to head.
struct CalculationView: View {
    // To access the stored teams and Pokemon, this View needs access to the database.
    @EnvironmentObject var database: DatabaseViewModel

    // Additionally, this View will need access to the damage calculation logic
    // and the Pokémon name to API number lookup.
    @State var calculator = CalculationViewModel()
    @State var pokemonNames = PokemonNamesViewModel()

    // The View will also need to fetch the base battle data for a Pokemon on the fly.
    let battleDataFetcher = BattleDataFetcher()

    // The View will be comparing two Teams.
    // This is optional in case no Teams have been created in the app yet.
    @State var team1: Team? = nil
    @State var team2: Team? = nil

    // In each team, there is also a particular Pokemon being selected.
    // This is represented as an integer which points to the index in the Team
    // that the current selection refers to.
    @State var pokemon1: Int = 0
    @State var pokemon2: Int = 0

    // The base battle data for each Pokemon also needs to be tracked.
    @State var battleData1: BattleDataFetcher.BattleData? = nil
    @State var battleData2: BattleDataFetcher.BattleData? = nil

    // The main battling functionality requires selecting a move,
    // displaying the percentage damage, and the type effectiveness of the move.
    @State var selectedMove: Int? = nil
    @State var damage: Double = 0
    @State var typeEffect: CalculationViewModel.Effectiveness = .immune

    // These two computed properties use the `pokemon1` and `pokemon2` indices to
    // conveniently output the actual `Pokemon` struct instance that it corresponds to,
    // allowing easier display of Pokemon-specific data and sprites.
    var selectedPokemon1: Pokemon? {
        return team1 == nil ? nil : database.pokemon.first { pokemon in
            pokemon.id == team1!.pokemonIDs[pokemon1]
        }
    }

    var selectedPokemon2: Pokemon? {
        return team2 == nil ? nil : database.pokemon.first { pokemon in
            pokemon.id == team2!.pokemonIDs[pokemon2]
        }
    }

    // These next two computed properties are here just to keep track of
    // changes in either a Team or a Pokemon, which is used to prompt
    // the recalculation of the HP bar damage display.
    var teamChanges: [Team?] {
        [team1, team2]
    }

    var pokemonChanges: [Int] {
        [pokemon1, pokemon2]
    }

    var body: some View {
        VStack {
            // This is the HP bar to visualise the amount of damage being done.
            Gauge(value: 1 - damage, in: 0...1) {
                EmptyView()
            } currentValueLabel: {
                let remainingHP = Int(100 * (1 - damage))
                VStack {
                    Text("Remaining HP: \(remainingHP)%")
                    typeEffectView()
                }
            }
            .tint(damage < 0.5 ? .green : damage < 0.75 ? .yellow : .red)
            .padding()

            // The main display of the Pokemon in their respective teams.
            Grid(horizontalSpacing: CGFloat(50)) {
                // In the top row, the swipable Pokémon sprites are displayed
                // as part of the team navigation functionality.
                GridRow {
                    // When changing between teams, the `pokemon1` and `pokemon2`
                    // states also need to be updated *before* the teams get updated.
                    // Otherwise, an index error will happen if the teams are of
                    // different sizes and the larger team has the last Pokemon selected.
                    // Hence, custom bindings which reset `pokemon1` and `pokemon2` to 0
                    // *before* the team update are passed to the team picker.
                    let teamBinding1 = Binding<Team?>(get: {
                        return self.team1
                    }, set: {
                        self.pokemon1 = 0
                        self.team1 = $0
                    })
                    let teamBinding2 = Binding<Team?>(get: {
                        return self.team2
                    }, set: {
                        self.pokemon2 = 0
                        self.team2 = $0
                    })
                    // These bindings are passed to the two columns in the first row.
                    teamPicker(teamBinding: teamBinding1, firstTeam: true)
                    teamPicker(teamBinding: teamBinding2, firstTeam: false)
                }
                // In the row below it is the display of the currently selected Pokemon.
                GridRow {
                    if let validPokemon1 = selectedPokemon1 {
                        let name = pokemonNames.getName(apiId: validPokemon1.pokemonNumber)
                        Text(name.readableFormat())
                            .font(.subheadline)
                    } else {
                        Text("No Pokémon selected")
                    }

                    if let validPokemon2 = selectedPokemon2 {
                        let name = pokemonNames.getName(apiId: validPokemon2.pokemonNumber)
                        Text(name.readableFormat())
                            .font(.subheadline)
                    } else {
                        Text("No Pokémon selected")
                    }
                }
                // The next row displays the combat stats of the selected Pokemon.
                GridRow {
                    if let validPokemon1 = selectedPokemon1, let validBattleData1 = battleData1 {
                        let stats1 = calculator.battleStats(pokemon: validPokemon1, pokemonData: validBattleData1)
                        BattleDataGridView(stats: stats1)
                    }

                    if let validPokemon2 = selectedPokemon2, let validBattleData2 = battleData2 {
                        let stats2 = calculator.battleStats(pokemon: validPokemon2, pokemonData: validBattleData2)
                        BattleDataGridView(stats: stats2)
                    }
                }
            }
            // At the bottom is the grid of all four moves from the first (left) Pokemon.
            Grid() {
                GridRow {
                    moveButton(index: 0)
                    moveButton(index: 1)
                }
                GridRow {
                    moveButton(index: 2)
                    moveButton(index: 3)
                }
            }
            .padding()

            // Underneath all of the main functionality is a convenience button
            // that allows the perspective to be swapped.
            Button {
                teamSwap()
            } label: {
                Text("Swap Teams")
            }
        }
        .task {
            // Upon startup, the name and API index lookup resource is populated.
            await pokemonNames.loadNames()
        }
        .onChange(of: selectedPokemon1) { oldValue, newValue in
            // The battle data state for the first Pokemon is updated
            // whenever its value changes.
            Task {
                if let num = newValue?.pokemonNumber {
                    battleData1 = await battleDataFetcher.fetch(num)
                }
            }
        }
        .onChange(of: selectedPokemon2) { oldValue, newValue in
            // The battle data state for the second Pokemon is updated
            // whenever its value changes.
            Task {
                if let num = newValue?.pokemonNumber {
                    battleData2 = await battleDataFetcher.fetch(num)
                }
            }
        }
        .onChange(of: teamChanges) { _, _ in
            // This ensures that the HP gauge is reset every time
            // something significant changes.
            reset()
        }
        .onChange(of: pokemonChanges) { _, _ in
            // This ensures that the HP gauge is reset every time
            // something significant changes.
            reset()
        }
        .onAppear {
            // The only teams available to be analysed are ones that
            // have at least one Pokemon in them.
            team1 = database.teams.filter { !$0.pokemonIDs.isEmpty }.first
            team2 = database.teams.filter { !$0.pokemonIDs.isEmpty }.first
        }
    }

    // Function to switch the selected teams and Pokemon.
    func teamSwap() {
        let tempTeam = team1
        team1 = team2
        team2 = tempTeam
        let tempPokemon = pokemon1
        pokemon1 = pokemon2
        pokemon2 = tempPokemon
    }

    /// This is a sub-view that wraps the team and Pokemon picker functionality.
    /// Since it occurs twice in the View, it is abstracted out to save repetition.
    func teamPicker(teamBinding: Binding<Team?>, firstTeam: Bool) -> some View {
        VStack {
            VStack {
                // The first team (team1) is the attacking team.
                // The second team is the defending team.
                Text(firstTeam ? "Attacking Team:" : "Defending Team:")
                    .bold()
                // The team can be selected here.
                Picker(selection: teamBinding, label: EmptyView()) {
                    ForEach(database.teams.filter { !$0.pokemonIDs.isEmpty }) { team in
                        Text(team.name)
                            .tag(team)
                    }
                }
            }
            // If there is no team available, a placeholder is displayed.
            // Otherwise, the `SwipeTeamView` is used to allow Pokemon selection.
            if let validTeam = teamBinding.wrappedValue {
                if firstTeam {
                    SwipeTeamView(team: validTeam, selectedIndex: $pokemon1, swipeDistance: CGFloat(50))
                } else {
                    SwipeTeamView(team: validTeam, selectedIndex: $pokemon2, swipeDistance: CGFloat(50))
                }
            } else {
                PokemonImageView(pokemonNumber: 0)
            }
        }
    }

    /// This is a sub-view that allows the selection of a move
    /// from the attacking Pokemon.
    /// Clicking on the move will cause the damage to be calculated and reflected
    /// in the HP gauge at the top.
    @ViewBuilder
    func moveButton(index: Int) -> some View {
        if let moves = selectedPokemon1?.moves {
            if moves.count > index {
                // The clickable button is only displayed if a move exists at
                // the provided `index` of the Pokemon's moveset.
                Button {
                    // When clicked, the damage is calculated and the HP gauge is updated.
                    selectedMove = index
                    calculateDamage(move: moves[index])
                } label: {
                    Text(moves[index].readableFormat())
                }
                .padding()
                .font(.headline)
                .frame(width: 175)
                .background(selectedMove == index ? Color.accentColor : .white)
                .foregroundStyle(selectedMove == index ? .white : Color.accentColor)
                .cornerRadius(12)
                .overlay(
                    selectedMove == index
                        ? AnyView(EmptyView())
                        : AnyView(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 1))
                )
            } else {
                Text("No Move")
                    .padding()
                    .font(.headline)
                    .frame(width: 175)
                    .cornerRadius(12)
                    .overlay(AnyView(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: 1)))
            }
        } else {
            Text("No Move")
                .padding()
                .font(.headline)
                .frame(width: 175)
                .cornerRadius(12)
                .overlay(AnyView(RoundedRectangle(cornerRadius: 12)
                    .stroke(.black, lineWidth: 1)))
        }
    }

    /// A sub-view to show the kind of type effectiveness that the move
    /// dealt against the defending Pokemon.
    func typeEffectView() -> some View {
        switch typeEffect {
        case .neutral:
            Text("It was neutral effectiveness.")
                .foregroundStyle(.black)
        case .weak:
            Text("It was super-effective!")
                .foregroundStyle(.green)
        case .resist:
            Text("It was not very effective...")
                .foregroundStyle(.orange)
        case .doubleWeak:
            Text("It was very super-effective!")
                .foregroundStyle(.green)
        case .doubleResist:
            Text("It was resisted heavily...")
                .foregroundStyle(.orange)
        case .immune:
            Text("No damage was taken!")
                .foregroundStyle(.black)
        }
    }

    /// This function triggers the damage calculation logic and updates
    /// the HP gauge, playing it with an animation for better visuals.
    func calculateDamage(move: String) {
        if let attackerPokemon = selectedPokemon1,
            let defenderPokemon = selectedPokemon2,
            let attackerData = battleData1,
            let defenderData = battleData2 {

            Task {
                if let (newDamage, typeModifier) = await calculator.calculateDamage(
                    move: move,
                    attacker: attackerPokemon,
                    attackerData: attackerData,
                    defender: defenderPokemon,
                    defenderData: defenderData) {

                    withAnimation {
                        damage = newDamage
                        typeEffect = typeModifier
                    }
                }
            }
        }
    }

    /// This function refreshes the HP gauge by setting it back to its default values,
    /// and also sets the selected move back to `nil` for a clean user experience.
    func reset() {
        withAnimation {
            damage = 0.0
            typeEffect = .immune
        }
        selectedMove = nil
    }
}

#Preview {
    CalculationView()
        .environmentObject(DatabaseViewModel())
}
