//
//  MainMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(InputModel.self) private var inputModel
    
    var body: some View {
        TabView {
            Tab("Start", systemImage: "play") {
                GameMenuView()
                    .gradientBackground(color: .indigo)
            }
            
            Tab("Racetrack", systemImage: "car.rear.road.lane") {
                TrackMenuView()
                    .gradientBackground(color: .purple)
            }
                
            Tab("Controls", systemImage: inputModel.method.metadata.systemImage) {
                InputMenuView()
                    .gradientBackground(color: .orange)
            }
            .badge(inputModel.inputIsAvailable ? nil : Text(""))
        }
    }
}



#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    MainMenuView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
        .environment(InputModel())
        .environment(GameModel())
        .environment(TrackDetectionModel())
}
