//
//  GameView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 29.11.24.
//

import SwiftUI

/// Shows the controls like stopping the game for the current GameMode.
struct GameView: View {
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            VStack {
                Text("Lapsrace")
                    .font(.largeTitle)
                    .padding(.bottom, 1.0)
                Label("Gamecontroller", systemImage: "gamecontroller")
                    .foregroundStyle(.secondary)
            }
            .padding(12.0)
            
            
            Button("Exit game", systemImage: "xmark", action: {
                showingAlert = true
            })
            .padding(12.0)
            .alert("Exit game", isPresented: $showingAlert) {
                Button("Exit", role: .destructive) { }
                Button("Cancel", role: .cancel) {}
            }
        }
        .gradientBackground(color: .indigo)
        .frame(width: 400, height: 250)
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 400, height: 250)) {
    GameView()
        .environment(GameModel())
}
