//
//  HandGestureInput.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import ARKit
import RealityKit

class HandGestureInput: HandtrackingInputProtocol {
    var speed: Float = 0
    var speedCurve: InputSpeedCurve = .linear
    
    var chirality: HandAnchor.Chirality = .right
    
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
}
