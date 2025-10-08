//
//  ShareExtensionView.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 9/10/2025.
//

import SwiftUI

struct ShareExtensionView: View {
    @State var text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Copied Text", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }
            .padding()
            .navigationTitle("Share Extension")
            .toolbar {
                Button("Cancel") {
                    self.close()
                }
            }
        }
    }

    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}
