//
//  AppIntent.swift
//  PokeCalcWidget
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This widget displays your first favourite Pokémon team." }
}
