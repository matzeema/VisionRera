//
//  HandGestureInput.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import ARKit
import RealityKit

@Observable
class HandGestureInput: HandtrackingInputProtocol {
    var speed: Float = 0
    var speedCurve: InputSpeedCurve = .linear
    
    /// Defines if the left or right hand should be used for input.
    var chirality: HandAnchor.Chirality = .right
    
    enum State {
        case unknown
        case ok
        case authenticationNotAllowed
        case handtrackingUnavailable
    }
    private(set) var state: State = .handtrackingUnavailable
    var isAvailable: Bool {
        state == .ok
    }
    
    /// Takes the AnchorUpdates from ARKitSessions via the HandTrackingProvider. Calulates the `speed` via the
    /// `calculateSpeedFromThumbTip` function.
    func update(from handAnchor: AnchorUpdate<HandAnchor>) {
        let anchor = handAnchor.anchor
        guard anchor.chirality == chirality else { return } // Filter hand anchors from the wrong hand
        guard let joint = anchor.handSkeleton?.joint(.thumbTip) else { return }
        
        speed = calculateSpeedFromThumbTip(joint: joint)
    }
    
    private func calculateSpeedFromThumbTip(joint: HandSkeleton.Joint) -> Float {
        let transform = Transform(matrix: joint.anchorFromJointTransform)
        let translationZ = transform.translation.z
        
        var speedResult = 1 - (((translationZ - 0.04) * 1.6666666) * 10)
        
        if speedResult > 1.0 { speedResult = 1.0 }
        if speedResult < 0.0 { speedResult = 0.0 }
        
        return speedResult
    }
    
    func onAuthenticationChanged(status: ARKitSession.AuthorizationStatus) {
        if status == .denied { state = .authenticationNotAllowed }
    }
    
    func onDataproviderStateChanged(state: DataProviderState) {
        if self.state == .authenticationNotAllowed { return } // Prioratize authorization issues over DataProvider issues
        if state == .paused || state == .stopped { self.state = .handtrackingUnavailable }
    }
    

}
