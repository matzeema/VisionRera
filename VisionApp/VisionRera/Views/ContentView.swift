//
//  ContentView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    @Environment(AppModel.self) private var appModel
    @Environment(RaceTrackManager.self) private var raceTrackManager
    
    var showLaunchView: Bool {
        return appModel.immersiveSpaceState == .open ||
                raceTrackManager.bleState != .poweredOn ||
                raceTrackManager.connectionState != .connected
    }

    var body: some View {
        if showLaunchView {
            WelcomeView()
        } else {
            Text("You are ready to play.")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
        .environment(RaceTrackManager())
}
