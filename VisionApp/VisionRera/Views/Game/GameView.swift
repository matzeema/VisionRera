//
//  GameView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 29.11.24.
//

import SwiftUI

/// Shows the controls like stopping the game for the current GameMode.
struct GameView: View {
    @Environment(GameModel.self) private var gameModel
    
    var body: some View {
        VStack {
            switch gameModel.mode {
            case .freeDrive: FreeDriveView()
            case .lapsRace: Text("Laps Race")
                
            default: EmptyView()
            }
        }
        .gradientBackground(color: .indigo)
    }
}

private struct FreeDriveView: View {
    @Environment(GameModel.self) private var gameModel
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Text(gameModel.mode?.metadata.name ?? "Free Drive")
                .font(.title)
                .padding(.horizontal, 18.0)
                .padding(.vertical, 6.0)
                
                Spacer()
                
                Button("Exit", systemImage: "xmark", action: {
                    showingAlert = true
                })
                .padding(6.0)
                .alert(
                    "Exit game",
                    isPresented: $showingAlert,
                    actions: {
                        Button("Exit", role: .destructive) {
                            gameModel.mode = nil
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                )
            }
            .padding(16.0)
            
            if let laps = gameModel.lapSessionFeature?.lapSessionFeature.laps {
            
                Divider()
                
                ScrollView {
                    ForEach(laps) { lap in
                        HStack {
                            Text("Lap \(lap.id)")
                                .font(.headline)
                                .padding(.leading, 16.0)
                                .padding(.vertical, 8.0)
                            
                            Text("\(lap.durationInMillis ?? 0) sek")
                        }
                    }
                }
                .foregroundStyle(.secondary)
                
            }
        }
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 400, height: 250)) {
    GameView()
        .environment(GameModel())
}
