//
//  GameMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct GameMenuView: View {
    @Environment(GameModel.self) private var gameModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16.0) {
                // TODO: Inform user about possible issues with Input or RaceTrack Detection
                // TODO: Don't allow starting a GameMode if any of the issues from above is active
                
                ForEach(GameModel.Mode.allCases, id: \.rawValue) { mode in
                    GameItemView(
                        name: mode.metadata.name,
                        description: mode.metadata.description,
                        startGameAction: {
                            gameModel.mode = mode
                        }
                    )
                }
            }
            .padding(32.0)
        }
    }
}

private struct GameItemView: View {
    let name: String
    let description: String
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
            }
            .padding(8.0)
            .frame(width: 500, alignment: .leading)

        }
        .hoverEffect()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    GameMenuView()
        .environment(RaceTrackModel())
        .environment(GameModel())
        
}
