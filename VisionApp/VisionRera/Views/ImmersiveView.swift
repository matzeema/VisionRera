//
//  ImmersiveView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

private enum AttachementsIDs {
    case speedHand
}

struct ImmersiveView: View {
    @Environment(ImmersiveModel.self) var immersiveModel
    @Environment(RaceTrackModel.self) var raceTrackModel
    @Environment(InputModel.self) var inputModel
    @Environment(TrackDetectionModel.self) var trackDetectionModel
    @Environment(GameModel.self) var gameModel
    
    /// Store handtracking anchor updates to show immersive AR-Elements around the hands of the user.
    var speedBarometerEntityHandler = SpeedBarometerEntityHandler()
    
    var raceInfoEntityHandler = RaceInfosEntityHandler()
    @State private var onLapFinishedSubscription: AnyCancellable?
    
    var body: some View {
        RealityView { content, attachments in
            speedBarometerEntityHandler.realityViewContent = content
            raceInfoEntityHandler.realityViewContent = content
            
            // Attachements
            if let attachement = attachments.entity(for: AttachementsIDs.speedHand) {
                speedBarometerEntityHandler.speedBarometerEntity = attachement
            }
            
        } update: { content, attachements in
            
            // Speed Barometer
            if gameModel.mode == nil {
                speedBarometerEntityHandler.enabled = false
                
            } else {
                // Set the position of the Speed Barometer based in the input method
                switch inputModel.method {
                case .handGesture:
                    speedBarometerEntityHandler.position = .topOfHand(chirality: inputModel.handGestureInput.chirality)
                case .gamepad:
                    speedBarometerEntityHandler.position = .gamecontrollerRelativeToHand(chirality: .right)
                }
                
                speedBarometerEntityHandler.enabled = true
            }
            
        } attachments: {
            Attachment(id: AttachementsIDs.speedHand) {
                SpeedBarometerView(speed: inputModel.speed)
            }
        }
        // Makes sure content is shown on top of the hands.
        .upperLimbVisibility(.hidden)
        
        // Inform SpeedBarometer and InputModel about Handtracking changes.
        .task {
            for await update in immersiveModel.handTracking.anchorUpdates {
                speedBarometerEntityHandler.updateWithAnchor(anchorUpdate: update)
                
                // Send handtracking data to InputModel if a handtracking input method is selected.
                if let handtrackingHandler = inputModel.handtrackingHandler {
                    handtrackingHandler.update(from: update)
                }
            }
        }
        // Inform TrackDetectionModel about barcode updates.
        .task {
            for await update in immersiveModel.barcodeDetection.anchorUpdates {
                trackDetectionModel.getBarcodeUpdate(update: update)
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
        
        // Inform the selected GameMode about changes of the input speed.
        .onChange(of: inputModel.speed) {
            if let gameModeHandler = gameModel.gameModeHandler {
                gameModeHandler.onSpeedInputChanged(speed: $1)
            }
        }
        // Inform the GameModel about if input is not available anymore.
        .onChange(of: inputModel.inputIsAvailable) {
            gameModel.onInputAvailabilityChanged(isAvailable: $1)
        }
        // Enable barcode detection if track detection is active.
        .onChange(of: trackDetectionModel.isDetecting) {
            immersiveModel.enableBarcodeDetection = $1
        }
        .onChange(of: gameModel.mode) {
            if $1 == nil {
                onLapFinishedSubscription?.cancel()
                raceInfoEntityHandler.removeAllRaceInfos()
                return
            }
            
            guard let trackInfo = trackDetectionModel.trackInfo else { return }
            raceInfoEntityHandler.setRaceInfosTransform(transform: trackInfo.transform)
            
            onLapFinishedSubscription = gameModel.lapSessionFeature?.lapSessionFeature.onLapFinishedPublisher.sink { lapInfo in
                // TODO: Only inform if fastestest Lap, not for every Lap
                raceInfoEntityHandler.requestRaceInfo(.fastestLap(lapInfo.lap))
            }
        }
    }
}
