//
//  GameMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct GameMenuView: View {
    @Environment(GameModel.self) private var gameModel
    @Environment(InputModel.self) private var inputModel
    
    var allRequiredDataIsAvailable: Bool {
        inputModel.inputIsAvailable
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if !inputModel.inputIsAvailable {
                    InfoGroupBox(
                        systemImageName: "exclamationmark.circle",
                        title: "Input method not available",
                        description: "Go to the Input Settings and update your input method."
                    )
                    .padding(.bottom, 16.0)
                }
                
                VStack(spacing: 16.0) {
                    ForEach(GameModel.Mode.allCases, id: \.rawValue) { mode in
                        GameItemView(
                            name: mode.metadata.name,
                            description: mode.metadata.description,
                            enabled: allRequiredDataIsAvailable,
                            startGameAction: {
                                gameModel.mode = mode
                            }
                        )
                    }
                }
                .foregroundStyle(allRequiredDataIsAvailable ? .primary : .secondary)
            }
            .padding(32.0)
        }
    }
}

private struct GameItemView: View {
    let name: String
    let description: String
    let enabled: Bool
    let startGameAction: () -> Void
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title)
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                Button(
                    action: startGameAction,
                    label: { Text("Start") }
                )
                .disabled(!enabled)
            }
            .padding(8.0)
        }
        .hoverEffect()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    GameMenuView()
        .environment(RaceTrackModel())
        .environment(GameModel())
        
}
