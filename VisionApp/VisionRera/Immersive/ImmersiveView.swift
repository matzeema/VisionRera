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
            
            if immersiveModel.enableHandTracking {
                Task {
                    for await update in immersiveModel.handTracking.anchorUpdates {
                        inputModel.updateHandTrackingInputMethod(handAnchor: update)
                    }
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(ImmersiveModel())
}
