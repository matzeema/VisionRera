//
//  SpeedBarometer.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 20.12.24.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

/// The SwiftUI Part of the SpeedBarometer Entity. Contains of a Gauge
/// with a Text at the bottom to show the speed in percentage.
struct SpeedBarometerView: View {
    let speed: Float
    let speedFormated: String
    
    var body: some View {
        Gauge(value: speed) {
            Text(speedFormated)
        }
        .gaugeStyle(.accessoryCircular)
    }
}

/// Manages the position and placement of the `SpeedBarometerView` as a RealityView-Attachement.
@MainActor
class SpeedBarometerEntityHandler {
    
    var realityViewContent: RealityViewContent?
    
    /// This entity has no visual representation and is only used to position other entities like the `speedBarometerEntity`.
    /// Its own position is the
    let handRootEntity = Entity()
    var speedBarometerEntity: ViewAttachmentEntity?
    
    /// Allows to enable or disable the handler. If disabled the Barometer gets removed
    /// from the RealityView and updates from the HandAnchors are ignored.
    var enabled = false {
        didSet {
            if enabled {
                addBarometerToContent()
            } else {
                removeBarometerFromContent()
            }
        }
    }
    
    private func addBarometerToContent() {
        guard let realityViewContent, let speedBarometerEntity else { return }
        realityViewContent.add(handRootEntity)
        handRootEntity.addChild(speedBarometerEntity) // TODO: Check if the child has to be added every single time after readding the entity to the scene
        
        updateSpeedBarometerPositionRelativeToRoot()
    }
    
    private func removeBarometerFromContent() {
        handRootEntity.removeFromParent()
    }
    
    /// Defines the position of the Barometer in the space. It can be placed on top of the hand or centered to a
    /// Gamecontroller realtive to a hand. Case 1 is normally used for the Handtracking-InputGesture. The
    /// second option for Gamecontrollers.
    enum Position {
        case topOfHand(chirality: HandAnchor.Chirality)
        case gamecontrollerRelativeToHand(chirality: HandAnchor.Chirality)
    }
    
    var position: Position = .topOfHand(chirality: .right) {
        didSet {
            updateSpeedBarometerPositionRelativeToRoot()
        }
    }
    
    /// Takes a HandAnchor and updates the root Entitiy based on the new position of the hand.
    func updateWithAnchor(anchorUpdate: AnchorUpdate<HandAnchor>) {
        if enabled == false { return }
         
        // Update the position of the `rootHandEntity`.
        switch position {
        case .topOfHand(let chirality):
            updateRootEntityPositionTopOfHand(
                rootEntity: handRootEntity,
                anchorUpdate: anchorUpdate,
                chirality: chirality
            )
            
        case .gamecontrollerRelativeToHand(let chirality):
            updateRootEntityPositionGameControllerRelativeToHand(
                rootEntity: handRootEntity,
                anchorUpdate: anchorUpdate,
                chirality: chirality
            )
        }
    }
    
    private func updateRootEntityPositionTopOfHand(rootEntity: Entity, anchorUpdate: AnchorUpdate<HandAnchor>, chirality: HandAnchor.Chirality) {
        if anchorUpdate.anchor.chirality != chirality { return }
        
        // Update position of root entity
        let transform = Transform(matrix: anchorUpdate.anchor.originFromAnchorTransform)
        rootEntity.move(to: transform, relativeTo: nil)
    }
     
    private func updateRootEntityPositionGameControllerRelativeToHand(rootEntity: Entity, anchorUpdate: AnchorUpdate<HandAnchor>, chirality: HandAnchor.Chirality) {
        // TODO: Implement
    }
    
    /// Updates the position of the `speedBarometerEntity` relative to the `handRootEntity`.
    private func updateSpeedBarometerPositionRelativeToRoot() {
        if enabled == false { return }
        
        switch position {
        case .topOfHand(let chirality):
            updateSpeedBarometerPositionRelativeToRootTopOfHand(chirality: chirality)
        case .gamecontrollerRelativeToHand(let chirality):
            updateSpeedBarometerPositionRelativeToRootGamecontroller(chirality: chirality)
        }
    }
    
    private func updateSpeedBarometerPositionRelativeToRootTopOfHand(chirality: HandAnchor.Chirality) {
        let chiralityMultiplier: Float = (chirality == .left ? -1 : 1)
        
        // TODO: Optimize position for left chirality
        
        let transform = Transform(
            rotation: simd_quatf(angle: .pi / 2, axis: [0, 0, 1]) * simd_quatf(angle: .pi / 4, axis: [1, 0, 0]) * chiralityMultiplier,
            translation: [-0.18, -0.03, 0.08] * chiralityMultiplier
        )
        
        speedBarometerEntity?.move(to: transform, relativeTo: handRootEntity)
    }
    
    private func updateSpeedBarometerPositionRelativeToRootGamecontroller(chirality: HandAnchor.Chirality) {
        // TODO: Implement
    }
}
