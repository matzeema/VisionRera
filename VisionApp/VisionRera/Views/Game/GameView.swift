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
                RaceContainerView(
                    name: gameModel.mode?.metadata.name ?? "Free Drive",
                    exitGameAction: { gameModel.mode = nil }
                ) {
                    FreeDriveView(laps: gameModel.lapSessionFeature?.lapSessionFeature.laps ?? [])
                }
            case .lapsRace:
                if let lapsRace = gameModel.gameModeHandler as? LapsRaceMode {
                    RaceContainerView(
                        name: gameModel.mode?.metadata.name ?? "Laps Race",
                        exitGameAction: { gameModel.mode = nil }
                    ) {
                        LapsRaceView(lapsRace: lapsRace)
                    }
                }
                
            default: EmptyView()
            }
        }
        .gradientBackground(color: .indigo)
    }
}

private struct RaceContainerView<Content: View>: View {
    @State private var showingAlert = false
    
    let name: String
    let exitGameAction: () -> Void
    let content: Content
    
    init(showingAlert: Bool = false, name: String, exitGameAction: @escaping () -> Void, @ViewBuilder _ content: () -> Content) {
        self.showingAlert = showingAlert
        self.name = name
        self.exitGameAction = exitGameAction
        self.content = content()
    }
    
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
            
            content
        }
    }
}

private struct FreeDriveView: View {
    let laps: [Lap]
    
    var body: some View {
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

private struct LapsRaceView: View {
    let lapsRace: LapsRaceMode
    
    var body: some View {
        Group {
            switch lapsRace.state {
            case .waitForCarPlaceAtStartline:
                VStack {
                    Image(systemName: "flag")
                        .font(.system(size: 36))
                        .padding(8.0)
                    Text("Place the car at the startline.")
                        .font(.title)
                }
                
            case .raceStartCountdown:
                VStack {
                    Text("\(lapsRace.countdownFeature.countdownValue)")
                        .font(.system(size: 84, weight: .bold))
                    Text("Lets get this race started!")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                
            case .racing:
                let laps = lapsRace.lapSessionFeature.laps
                ScrollView {
                    VStack {
                        ForEach(laps.sorted(by: { a,b in a.id > b.id })) { lap in
                            if lap.isFinished {
                                HStack {
                                    Text("Lap \(lap.id)/\(LapsRaceMode.lapsCount)")
                                        .font(.headline)
                                        .padding(.vertical, 4.0)
                                        .padding(.trailing, 8.0)
                                    
                                    Text("\(lap.durationInMillis ?? 0) sek")
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                
            case .carCrash:
                VStack {
                    Image(systemName: "steeringwheel.badge.exclamationmark")
                        .font(.system(size: 36))
                        .padding(8.0)
                    Text("Car crashed!")
                        .font(.title)
                    Text("Put the car back on the track.")
                        .foregroundStyle(.secondary)
                }
                
            case .restartCountdown:
                VStack {
                    Text("\(lapsRace.countdownFeature.countdownValue)")
                        .font(.system(size: 84, weight: .bold))
                    Text("Lets get back on track!")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                
            case .finishedRace:
                VStack {
                    HStack {
                        Text("Race finished")
                        Image(systemName: "flag.pattern.checkered")
                    }
                    .font(.title)
                    .padding(8.0)
                    
                    VStack {
                        Text("Duration: \(lapsRace.lapSessionFeature.durationOfSessionInMillis) millis")
                        Text("Fastest lap: \(lapsRace.lapSessionFeature.fastestLapDuration ?? 0) millis")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}



#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    RaceContainerView(name: "Free Drive", exitGameAction: {}) {
        FreeDriveView(
            laps: [
                Lap(id: 1, startMillis: 0, endMillis: 2000),
                Lap(id: 2, startMillis: 2000, endMillis: 2357),
                Lap(id: 3, startMillis: 2357, endMillis: 2942),
                Lap(id: 4, startMillis: 2942, endMillis: 3447),
                Lap(id: 5, startMillis: 3447, endMillis: 4001),
                Lap(id: 6, startMillis: 3447)
            ]
        )
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    RaceContainerView(name: "Laps Race", exitGameAction: {}) {
        LapsRaceView(lapsRace: LapsRaceMode()) 
    }
}
