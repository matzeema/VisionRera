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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(immersiveModel)
                .environment(raceTrackModel)
        }
        .defaultSize(width: 600, height: 400)

        ImmersiveSpace(id: immersiveModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(immersiveModel)
                .environment(raceTrackModel)
                .onAppear {
                    immersiveModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    immersiveModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
