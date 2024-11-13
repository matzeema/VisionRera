//
//  HandGestureInput.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import ARKit

struct HandGestureInput: HandtrackingInputProtocol {
    var speed: Float = 0
    var speedCurve: InputSpeedCurve = .linear
    
    func update(from handAnchor: HandAnchor) {
        <#code#>
    }
    
    // TODO: Implement HandGesture support
}
