//
//  LapsRaceMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation

@Observable
class LapsRaceMode: GameModeProtocol, LapSessionProtocol, CrashDetectionProtocol {
    var speedToRaceTrack: Float = 0
    var lapSessionFeature: LapSessionFeature = LapSessionFeature()
    
    func onSpeedInputChanged(speed: Float) {
        
    }
}
