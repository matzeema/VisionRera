//
//  ContentView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    @Environment(ImmersiveModel.self) private var immersiveModel
    @Environment(RaceTrackModel.self) private var raceTrackModel
    
    var showLaunchView: Bool {
        return immersiveModel.immersiveSpaceState != .open ||
                raceTrackModel.bleState != .poweredOn ||
                raceTrackModel.connectionState != .connected
    }

    var body: some View {
        if showLaunchView {
            WelcomeView()
        } else {
            MainMenuView()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
}
