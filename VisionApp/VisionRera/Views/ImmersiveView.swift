//
//  ImmersiveView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {
    @Environment(ImmersiveModel.self) var immersiveModel
    @Environment(RaceTrackModel.self) var raceTrackModel
    @Environment(InputModel.self) var inputModel
    @Environment(TrackDetectionModel.self) var trackDetectionModel
    @Environment(GameModel.self) var gameModel


    var body: some View {
        RealityView { content in
            
        } update: { content in
            
        }
        // Send handtracking data to InputModel if a handtracking input method is selected.
        .onChange(of: inputModel.inputRequiresHandtrackingData, initial: true) {
            immersiveModel.enableHandTracking = inputModel.inputRequiresHandtrackingData
            
            if let handtrackingHandler = inputModel.handtrackingHandler {
                Task {
                    for await update in immersiveModel.handTracking.anchorUpdates {
                        handtrackingHandler.update(from: update)
                    }
                }
            }
        }
        // Inform InputModel about data provider changes if a handtracking input method is selected.
        .onChange(of: immersiveModel.handTracking.state) {
            if let handtrackingHandler = inputModel.handtrackingHandler {
                handtrackingHandler.onDataproviderStateChanged(state: $1)
            }
        }
        // Inform InputModel about handtracking auth state changes if a handtracking input method is selected.
        .onChange(of: immersiveModel.handTrackingAuthStatus) {
            if let handtrackingHandler = inputModel.handtrackingHandler {
                handtrackingHandler.onAuthenticationChanged(status: $1)
            }
        }
        .onChange(of: inputModel.speed) {
            if let gameModeHandler = gameModel.gameModeHandler {
                gameModeHandler.onSpeedInputChanged(speed: $1)
            }
        }
        // Inform GameModel about finishline sensor triggers if a game mode with lap session feature is selected.
        .onChange(of: raceTrackModel.getLastTriggerFinishlineSensor() ?? 0) {
            if let mode = gameModel.lapSessionFeature {
                mode.lapSessionFeature.carDroveOverFinishline($1)
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(ImmersiveModel())
}
