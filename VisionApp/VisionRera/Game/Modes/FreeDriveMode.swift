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
    var speedToRaceTrackState: SpeedToRacetrackState = .stop
    var lapSessionFeature: LapSessionFeature = LapSessionFeature()
    
    private var onLapFinishedSubscription: AnyCancellable?
    
    init() {
        onLapFinishedSubscription = lapSessionFeature.onLapFinishedPublisher.sink { lap in
            print(lap)
        }
    }
}
