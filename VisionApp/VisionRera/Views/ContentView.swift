//
//  ContentView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import RealityKit

/// Decides which Main UI-Component will be shown. The app contains of the
/// LaunchView, MainMenu and the GameView Components.
///
/// - LaunchView: Setup and connection with the RaceTrack, Opens the Immersive Space
/// - MainMenu: Start the Game, Detect the Track, Set Input-Options.
/// - GameView: Give a window anker to exit the game, Show basic information about the GameMode
struct ContentView: View {
    
    @Environment(ImmersiveModel.self) private var immersiveModel
    @Environment(RaceTrackModel.self) private var raceTrackModel
    @Environment(GameModel.self) private var gameModel
    
    var showLaunchView: Bool {
        return immersiveModel.immersiveSpaceState != .open ||
                raceTrackModel.bleState != .poweredOn ||
                raceTrackModel.connectionState != .connected
    }

    var body: some View {
        if showLaunchView {
            LaunchView()
            
        } else if (gameModel.mode == .none) {
            MainMenuView()
            
        } else {
            GameView()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
}
