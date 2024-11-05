//
//  ImmersiveModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 09.10.24.
//

import SwiftUI
import ARKit

/// Maintains state related to immersive spcaes and AR.
@MainActor
@Observable
class ImmersiveModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    /// The ARKitSession of the app.
    let arKitSession = ARKitSession()
}
