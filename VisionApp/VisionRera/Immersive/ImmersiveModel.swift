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
    var immersiveSpaceState = ImmersiveSpaceState.closed {
        didSet {
            switch immersiveSpaceState {
            case .closed:
                Task {
                    await arKitSession.stop()
                }
            case .open:
                Task {
                    await runARKitSession()
                }
                
            default:
                break
            }
        }
    }
    
    /// The ARKitSession of the app.
    let arKitSession = ARKitSession()
    let handTracking = HandTrackingProvider()
    
    var enableHandTracking = false {
        didSet {
            Task {
                await runARKitSession()
            }
        }
    }
    
    /// Runs the ARKitSession for all enabled tracking providers.
    private func runARKitSession() async {
        var dataProviders: [any DataProvider] = []
        
        if HandTrackingProvider.isSupported && enableHandTracking {
            dataProviders.append(handTracking)
        }
        
        do {
            try await arKitSession.run(dataProviders)
        } catch {
            print("ARKitSession failed to run: \(error)")
        }
    }
    
}
