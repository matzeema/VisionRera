//
//  FreeDriveMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

@Observable
class FreeDriveMode: GameModeProtocol, LapSessionProtocol, CrashDetectionProtocol {
    var speedToRaceTrack: Float = 0
    var lapSessionFeature: LapSessionFeature = LapSessionFeature()
    
    private var onLapFinishedSubscription: AnyCancellable?
    
    init() {
        onLapFinishedSubscription = lapSessionFeature.onLapFinishedPublisher.sink { lap in
            print(lap)
        }
    }
    
    func onSpeedInputChanged(speed: Float) {
        speedToRaceTrack = speed
    }
}
