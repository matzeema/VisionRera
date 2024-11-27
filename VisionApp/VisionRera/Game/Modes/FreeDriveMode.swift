//
//  FreeDriveMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation

@Observable
class FreeDriveMode: GameModeProtocol, LapSessionProtocol, CrashDetectionProtocol {
    var speedToRaceTrackState: SpeedToRacetrackState = .stop
    var lapSessionFeature: LapSessionFeature = LapSessionFeature()
    
}
