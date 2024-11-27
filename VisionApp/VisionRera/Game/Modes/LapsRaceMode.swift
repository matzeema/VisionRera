//
//  LapsRaceMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation

@Observable
class LapsRaceMode: GameModeProtocol, LapSessionProtocol, CrashDetectionProtocol {
    var speedToRaceTrackState: SpeedToRacetrackState = .stop
    var lapSessionFeatures: LapSessionFeature = LapSessionFeature()
}
