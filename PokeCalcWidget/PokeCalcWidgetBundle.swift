//
//  PokeCalcWidgetBundle.swift
//  PokeCalcWidget
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct PokeCalcWidgetBundle: WidgetBundle {
    var body: some Widget {
        PokeCalcWidget()
        PokeCalcWidgetControl()
        PokeCalcWidgetLiveActivity()
    }
}
