//
//  VisionReraApp.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI

@main
struct VisionReraApp: App {

    @State private var appModel = AppModel()
    @State private var raceTrackManager = RaceTrackManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(raceTrackManager)
        }
        .defaultSize(width: 600, height: 400)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(raceTrackManager)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
