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
    var worldSensingAuthStatus = ARKitSession.AuthorizationStatus.notDetermined
    var handTrackingAuthStatus = ARKitSession.AuthorizationStatus.notDetermined
    
    var handTracking = HandTrackingProvider()
    var enableHandTracking = true {
        didSet {
            Task { await runARKitSession() }
        }
    }
    
    var barcodeDetection = BarcodeDetectionProvider(symbologies: [.qr])
    var enableBarcodeDetection = false {
        didSet {
            Task { await runARKitSession() }
        }
    }
    
    /// Runs the ARKitSession for all enabled tracking providers.
    private func runARKitSession() async {
        var dataProviders: [any DataProvider] = []
        
        // Handtracking
        if HandTrackingProvider.isSupported && enableHandTracking {
            if handTracking.state == .stopped {
                // It is not possible to re-run a stopped data provider.
                // -> Create a new HandTrackingProvider instance
                handTracking = HandTrackingProvider()
            }
            
            dataProviders.append(handTracking)
        }
        
        // Barcode detection
        if BarcodeDetectionProvider.isSupported {
            if barcodeDetection.state == .stopped && enableBarcodeDetection {
                // It is not possible to re-run a stopped data provider.
                // -> Create a new BarcodeDetectionProvider instance
                barcodeDetection = BarcodeDetectionProvider(symbologies: [.qr])
            }
            
            dataProviders.append(barcodeDetection)
        }
        
        do {
            try await arKitSession.run(dataProviders)
            
            // Listen for ARKitSession events
            for await event in arKitSession.events {
                switch event {
                case .authorizationChanged(type: let type, status: let status):
                    switch type {
                    case .worldSensing: worldSensingAuthStatus = status
                    case .handTracking: handTrackingAuthStatus = status
                    default: break
                    }
                default: break
                }
            }
        } catch {
            print("ARKitSession failed to run: \(error)")
        }
    }
    
    private func stopARKitSession() {
        arKitSession.stop()
    }
    
    /// This function should be used if data providers have been stoped and user wants to manually restart them.
    func tryRerunARKitSession() async {
        await runARKitSession()
    }
}
