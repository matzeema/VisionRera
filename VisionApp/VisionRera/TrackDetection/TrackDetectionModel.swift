//
//  TrackDetectionModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

/// Manages the state of detected barcodes and their positions in a visionOS app.
@MainActor
@Observable
class TrackDetectionModel {
    
    /// Indicates whether the barcode detection process is currently active.
    var isDetecting = false

    struct Track {
        let marker: TrackMarker
        let transform: Transform
    }
    private(set) var track: Track?
    
    func getBarcodeUpdate(update: AnchorUpdate<BarcodeAnchor>) {
        if isDetecting == false { return }
        if update.event != .added { return }
        
        guard let payloadString = update.anchor.payloadString?.data(using: .utf8) else { return }
        guard let trackMarker = createTrackMarker(payload: payloadString) else { return }
        
        track = Track(
            marker: trackMarker,
            transform: Transform(matrix: update.anchor.originFromAnchorTransform)
        )
        
        isDetecting = false
    }
    
    private func createTrackMarker(payload: Data) -> TrackMarker? {
        do {
            let trackMarker = try JSONDecoder().decode(TrackMarker.self, from: payload)
            return trackMarker
            
        } catch {
            print("Fehler beim Dekodieren: \(error)")
            return nil
        }
    }
}

struct TrackMarker: Codable {
    var trackId: String
    var markerType: MarkerType
    
    enum MarkerType: String, Codable {
        case startAndFinish
    }
}
