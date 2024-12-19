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
            case .freeDrive:
                FreeDriveView(
                    name: gameModel.mode?.metadata.name ?? "Free Drive",
                    laps: gameModel.lapSessionFeature?.lapSessionFeature.laps ?? [],
                    exitGameAction: { gameModel.mode = nil }
                )
            case .lapsRace: Text("Laps Race")
                
            default: EmptyView()
            }
        }
        .gradientBackground(color: .indigo)
    }
}

private struct FreeDriveView: View {
    @State private var showingAlert = false
    
    let name: String
    let laps: [Lap]
    let exitGameAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.title)
                    .padding(.horizontal, 18.0)
                    .padding(.vertical, 4.0)
                
                Spacer()
                
                Button("Exit", systemImage: "xmark", action: {
                    showingAlert = true
                })
                .padding(.horizontal, 6.0)
                .alert(
                    "Exit game",
                    isPresented: $showingAlert,
                    actions: {
                        Button("Exit", role: .destructive, action: exitGameAction)
                        Button("Cancel", role: .cancel) {}
                    }
                )
            }
            .padding(16.0)
            
            Divider()
            
            ScrollView {
                VStack {
                    ForEach(laps.sorted(by: { a,b in a.id > b.id })) { lap in
                        if lap.isFinished {
                            HStack {
                                Text("Lap \(lap.id)")
                                    .font(.headline)
                                    .padding(.vertical, 4.0)
                                    .padding(.trailing, 8.0)
                                
                                Text("\(lap.durationInMillis ?? 0) sek")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
            .foregroundStyle(.secondary)
        }
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    FreeDriveView(
        name: "Free Drive",
        laps: [
            Lap(id: 1, startMillis: 0, endMillis: 2000),
            Lap(id: 2, startMillis: 2000, endMillis: 2357),
            Lap(id: 3, startMillis: 2357, endMillis: 2942),
            Lap(id: 4, startMillis: 2942, endMillis: 3447),
            Lap(id: 5, startMillis: 3447, endMillis: 4001),
            Lap(id: 6, startMillis: 3447)
        ],
        exitGameAction: {}
    )
}
