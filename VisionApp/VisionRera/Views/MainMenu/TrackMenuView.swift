//
//  TrackMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.05.25.
//

import SwiftUI
import RealityKit

struct TrackMenuView: View {
    @Environment(TrackDetectionModel.self) private var trackDetection
    
    var body: some View {
        @Bindable var trackDetection = trackDetection
        VStack(spacing: 20) {
            
            // Track detected view
            if let track = trackDetection.trackInfo {
                Text("Track Detected")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Track ID: \(track.marker.trackId)")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Button("Scan New Track") {
                    trackDetection.isDetecting = true
                }
                .buttonStyle(.borderedProminent)
                
            // No track detected view
            } else {
                Text("No position defined")
                    .font(.largeTitle)
                
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Scan Track Barcode") {
                    trackDetection.isDetecting = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .sheet(isPresented: $trackDetection.isDetecting) {
            ScanModalView(model: trackDetection, isPresented: $trackDetection.isDetecting)
        }
    }
}

struct ScanModalView: View {
    let model: TrackDetectionModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scanning for Track Barcode...")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Look at the barcode on the start of track.")
                .foregroundStyle(.secondary)
            
            Button("Cancel") {
                isPresented = false
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    TrackMenuView()
        .environment(TrackDetectionModel())
        .gradientBackground(color: .purple)
}
