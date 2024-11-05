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
            
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(ImmersiveModel())
}
