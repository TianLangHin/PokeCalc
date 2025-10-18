//
//  CalculationView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 18/10/2025.
//

import SwiftUI

struct CalculationView: View {
    @EnvironmentObject var database: DatabaseViewModel
    @State var calculator = CalculationViewModel()
    @State var pokemonNames = PokemonNamesViewModel()

    let battleDataFetcher = BattleDataFetcher()

    @State var team1: Team? = nil
    @State var team2: Team? = nil

    @State var pokemon1: Int = 0
    @State var pokemon2: Int = 0

    @State var battleData1: BattleDataFetcher.BattleData? = nil
    @State var battleData2: BattleDataFetcher.BattleData? = nil

    @State var selectedMove: Int = 0

    @State var damage: Double = 0

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

    var teamChanges: [Team?] {
        [team1, team2]
    }

    var pokemonChanges: [Int] {
        [pokemon1, pokemon2]
    }

    var body: some View {
        VStack {
            Gauge(value: 1 - damage, in: 0...1) {
                EmptyView()
            } currentValueLabel: {
                let remainingHP = Int(100 * (1 - damage))
                Text("Remaining HP: \(remainingHP)%")
            }
            .tint(damage < 0.5 ? .green : damage < 0.75 ? .yellow : .red)
            .padding()
            Grid() {
                GridRow {
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
                    teamPicker(teamBinding: teamBinding1, firstTeam: true)
                    teamPicker(teamBinding: teamBinding2, firstTeam: false)
                }
                GridRow {
                    if let validPokemon1 = selectedPokemon1 {
                        let name = pokemonNames.getName(apiId: validPokemon1.pokemonNumber)
                        Text(name.readableFormat())
                    } else {
                        Text("No Pokémon selected")
                    }
                    if let validPokemon2 = selectedPokemon2 {
                        let name = pokemonNames.getName(apiId: validPokemon2.pokemonNumber)
                        Text(name.readableFormat())
                    } else {
                        Text("No Pokémon selected")
                    }
                }
                GridRow {
                    if let validPokemon1 = selectedPokemon1,
                       let validBattleData1 = battleData1 {
                        let stats = calculator.battleStats(pokemon: validPokemon1, pokemonData: validBattleData1)
                        Text("\(stats)")
                    } else {
                        Text("No stats")
                    }
                    if let validPokemon2 = selectedPokemon2,
                       let validBattleData2 = battleData2 {
                        let stats = calculator.battleStats(pokemon: validPokemon2, pokemonData: validBattleData2)
                        Text("\(stats)")
                    } else {
                        Text("No stats")
                    }
                }
            }
            .padding()
            Button {
                let tempTeam = team1
                team1 = team2
                team2 = tempTeam
                let tempPokemon = pokemon1
                pokemon1 = pokemon2
                pokemon2 = tempPokemon
            } label: {
                Text("Swap")
            }
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
        }
        .task {
            await pokemonNames.loadNames()
        }
        .onChange(of: selectedPokemon1) { oldValue, newValue in
            Task {
                if let num = newValue?.pokemonNumber {
                    battleData1 = await battleDataFetcher.fetch(num)
                }
            }
        }
        .onChange(of: selectedPokemon2) { oldValue, newValue in
            Task {
                if let num = newValue?.pokemonNumber {
                    battleData2 = await battleDataFetcher.fetch(num)
                }
            }
        }
        .onChange(of: teamChanges) { _, _ in
            reset()
        }
        .onChange(of: pokemonChanges) { _, _ in
            reset()
        }
        .onAppear {
            team1 = database.teams.first
            team2 = database.teams.first
        }
    }

    func teamPicker(teamBinding: Binding<Team?>, firstTeam: Bool) -> some View {
        VStack {
            if let validTeam = teamBinding.wrappedValue {
                if firstTeam {
                    SwipeTeamView(team: validTeam, selectedIndex: $pokemon1, size: 200)
                } else {
                    SwipeTeamView(team: validTeam, selectedIndex: $pokemon2, size: 200)
                }

            } else {
                PokemonImageView(pokemonNumber: 0)
                    .frame(width: 200, height: 200)
            }
            Picker(selection: teamBinding, label: EmptyView()) {
                ForEach(database.teams.filter { !$0.pokemonIDs.isEmpty }) { team in
                    HStack {
                        Text(team.name)
                    }
                    .tag(team)
                }
            }
        }
    }

    @ViewBuilder
    func moveButton(index: Int) -> some View {
        if let moves = selectedPokemon1?.moves {
            if moves.count > index {
                Button {
                    selectedMove = index
                    calculateDamage(move: moves[index])
                } label: {
                    Text(moves[index].readableFormat())
                        .border(selectedMove == index ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("No move to select!")
                    .border(selectedMove == index ? .black : .white)
            }
        } else {
            Text("Select a Pokémon first!")
                .border(selectedMove == index ? .black : .white)
        }
    }

    func calculateDamage(move: String) {
        Task {
            if let attackerPokemon = selectedPokemon1,
               let defenderPokemon = selectedPokemon2,
               let attackerData = battleData1,
               let defenderData = battleData2 {

                damage = await calculator.calculateDamage(
                    move: move,
                    attacker: attackerPokemon,
                    attackerData: attackerData,
                    defender: defenderPokemon,
                    defenderData: defenderData) ?? 0.0
            }
        }
    }

    func reset() {
        damage = 0.0
        selectedMove = 0
    }
}

#Preview {
    CalculationView()
        .environmentObject(DatabaseViewModel())
}
