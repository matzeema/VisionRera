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
            case .closed: stopARKitSession()
            case .open:   Task { await runARKitSession() }
            default: break
            }
        }
    }
    
    /// The ARKitSession of the app.
    let arKitSession = ARKitSession()
    var handTracking = HandTrackingProvider()
    var barcodeDetection = BarcodeDetectionProvider(symbologies: [.qr])
    
    var enableHandTracking = false {
        didSet {
            Task { await runARKitSession() }
        }
    }
    
    var enableBarcodeDetection = true {
        didSet {
            Task { await runARKitSession() }
        }
    }
    
    /// Runs the ARKitSession for all enabled tracking providers.
    private func runARKitSession() async {
        var dataProviders: [any DataProvider] = []
        
        if HandTrackingProvider.isSupported && enableHandTracking {
            // It is not possible to re-run a stopped data provider.
            // -> Create a new HandTrackingProvider instance
            handTracking = HandTrackingProvider()
            
            dataProviders.append(handTracking)
        }
        
        if BarcodeDetectionProvider.isSupported && enableBarcodeDetection {
            barcodeDetection = BarcodeDetectionProvider(symbologies: [.qr])
            
            dataProviders.append(barcodeDetection)
        }
        
        do {
            try await arKitSession.run(dataProviders)
            
            for await update in barcodeDetection.anchorUpdates {
                print(update)
            }
        } catch {
            print("ARKitSession failed to run: \(error)")
        }
    }
    
    private func stopARKitSession() {
        arKitSession.stop()
    }
    
}
