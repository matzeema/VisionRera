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
class SpeedBarometerEntityHandler {
    
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
    
    var realityViewContent: RealityViewContent?
    var speedBarometerEntity: ViewAttachmentEntity?
    
    private func addBarometerToContent() {
        guard let realityViewContent, let speedBarometerEntity else { return }
        realityViewContent.add(speedBarometerEntity)
    }
    
    private func removeBarometerFromContent() {
        guard let realityViewContent, let speedBarometerEntity else { return }
        realityViewContent.remove(speedBarometerEntity)
    }
    
    /// Defines the position of the Barometer in the space. It can be placed on top of the hand or centered to a
    /// Gamecontroller realtive to a hand. Case 1 is normally used for the Handtracking-InputGesture. The
    /// second option for Gamecontrollers.
    enum Position {
        case topOfHand(chirality: HandAnchor.Chirality)
        case gamecontrollerRelativeToHand(chirality: HandAnchor.Chirality)
    }
    
    var position: Position = .topOfHand(chirality: .right)
    
    func updateWithAnchor(anchorUpdate: AnchorUpdate<HandAnchor>) {
        if enabled == false { return }
        guard let speedBarometerEntity else { return }
         
        switch position {
        case .topOfHand(let chirality):
            updateEntityPositionTopOfHand(
                entity: speedBarometerEntity, anchorUpdate: anchorUpdate, chirality: chirality
            )
            
        case .gamecontrollerRelativeToHand(let chirality):
            updateEntityPositionGameControllerRelativeToHand(
                entity: speedBarometerEntity, anchorUpdate: anchorUpdate, chirality: chirality
            )
        }
    }
    
    private func updateEntityPositionTopOfHand(entity: Entity, anchorUpdate: AnchorUpdate<HandAnchor>, chirality: HandAnchor.Chirality) {
        if anchorUpdate.anchor.chirality != chirality { return }
        
        var anchorTransform = Transform(matrix: anchorUpdate.anchor.originFromAnchorTransform)
        
        anchorTransform.translation.y += 0.12
        anchorTransform.translation.z += 0.05
        anchorTransform.rotation = .init(angle: 0, axis: [0, 1, 0])
        
        entity.move(to: anchorTransform, relativeTo: nil)
    }
     
    private func updateEntityPositionGameControllerRelativeToHand(entity: Entity, anchorUpdate: AnchorUpdate<HandAnchor>, chirality: HandAnchor.Chirality) {
        // TODO: Implement
    }
}
