//
//  LapsRaceMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

@Observable
class LapsRaceMode: GameModeProtocol, LapSessionProtocol, CrashDetectionProtocol {
    var speedToRaceTrack: Float = 0
    var lapSessionFeature = LapSessionFeature()
    var crashDetectionFeature = CrashDetectionFeature()
    
    private var onLapFinishedSubscription: AnyCancellable?
    private var onCarCrashSubscription: AnyCancellable?
    
    init() {
        onLapFinishedSubscription = lapSessionFeature.onLapFinishedPublisher.sink { lap in
            print(lap)
        }
        
        onCarCrashSubscription = crashDetectionFeature.onCarCrashedPublisher.sink { _ in
            print("Crash detected!")
        }
        
        lapSessionFeature.enabled = true
        crashDetectionFeature.enabled = true
    }
    
    func onSpeedInputChanged(speed: Float) {
        
    }
}
