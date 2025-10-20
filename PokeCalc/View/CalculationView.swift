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

    @State var selectedMove: Int? = nil

    @State var damage: Double = 0
    @State var typeEffect: CalculationViewModel.Effectiveness = .immune

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
                VStack {
                    Text("Remaining HP: \(remainingHP)%")
                    typeEffectView()
                }
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
            
            Button {
                teamSwap()
            } label: {
                Text("Swap")
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
    
    func teamSwap() {
        let tempTeam = team1
        team1 = team2
        team2 = tempTeam
        let tempPokemon = pokemon1
        pokemon1 = pokemon2
        pokemon2 = tempPokemon
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
            
            HStack {
                Text("Select Team:")
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
                    
                }
                .padding()
                .font(.headline)
                .frame(width: 175)
                .background(selectedMove == index ? Color.accentColor : .white)
                .foregroundStyle(selectedMove == index ? .white : Color.accentColor)
                .cornerRadius(12)
                .overlay(
                    selectedMove == index ? AnyView(EmptyView()) : AnyView(RoundedRectangle(cornerRadius: 12)
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
            Text("Select a Pokémon first!")
                .border(selectedMove == index ? .black : .white)
        }
    }

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
