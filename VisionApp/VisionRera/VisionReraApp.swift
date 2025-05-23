//
//  VisionReraApp.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI

@main
struct VisionReraApp: App {

    @State private var immersiveModel = ImmersiveModel()
    @State private var raceTrackModel = RaceTrackModel()
    @State private var inputModel = InputModel()
    @State private var trackDetectionModel = TrackDetectionModel()
    @State private var gameModel = GameModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(immersiveModel)
                .environment(raceTrackModel)
                .environment(inputModel)
                .environment(trackDetectionModel)
                .environment(gameModel)
                .onAppear {
                    // Disable window resizing from the user
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        return
                    }
                        
                    windowScene.requestGeometryUpdate(.Vision(resizingRestrictions: UIWindowScene.ResizingRestrictions.none))
                }
        }
        .defaultSize(width: 600, height: 400)

        ImmersiveSpace(id: immersiveModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(immersiveModel)
                .environment(raceTrackModel)
                .environment(inputModel)
                .environment(trackDetectionModel)
                .environment(gameModel)
                .onAppear {
                    immersiveModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    immersiveModel.immersiveSpaceState = .closed
                }
            // Update the speed on the RaceTrack with the one delivered by the GameModel.
            .onChange(of: gameModel.gameModeHandler?.speedToRaceTrack) {
                if let speed = $1 {
                    raceTrackModel.setSpeed(speed: speed)
                } else {
                    // Stop the cars if GameMode was canceled.
                    raceTrackModel.setSpeed(speed: 0.0)
                }
            }
            // Inform GameModel about finishline sensor triggers if a game mode with lap session feature is selected.
            .onChange(of: raceTrackModel.getLastTriggerFinishlineSensor() ?? 0) {
                if let mode = gameModel.lapSessionFeature {
                    mode.lapSessionFeature.carDroveOverFinishline($1)
                }
            }
            // Inform GameModel about car-on-track state changes.
            .onChange(of: raceTrackModel.getCarOnTrackState()) {
                if let crashDetection = gameModel.crashDetectionFeature,
                   let state = $1 {
                    crashDetection.crashDetectionFeature.onCarOnTrackStateChanged(state: state)
                }
            }
            // Inform GameModel about car at startline changes.
            .onChange(of: raceTrackModel.getCarStandsOnSensor()) {
                if let carAtStartlineFeature = gameModel.carAtStartlineFeature {
                    carAtStartlineFeature.carStandsAtStartline($1)
                }
            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
