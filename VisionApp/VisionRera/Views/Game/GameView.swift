//
//  GameView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 29.11.24.
//

import SwiftUI

/// Shows the controls like stopping the game for the current GameMode.
struct GameView: View {
    @Environment(GameModel.self) private var gameMode
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Text(gameMode.mode?.metadata.name ?? "Unknown Game Mode")
                .font(.largeTitle)
                .padding(12.0)
            
            
            
            Button("Exit game", systemImage: "xmark", action: {
                showingAlert = true
            })
            .padding(12.0)
            .alert(
                "Exit game",
                isPresented: $showingAlert,
                actions: {
                    Button("Exit", role: .destructive) {
                        gameMode.mode = nil
                    }
                    Button("Cancel", role: .cancel) {}
                },
                message: {
                    Text("No highscores will be stored.")
                }
            )
        }
        .gradientBackground(color: .indigo)
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 400, height: 250)) {
    GameView()
        .environment(GameModel())
}
