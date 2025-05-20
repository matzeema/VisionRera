//
//  LapSessionManager.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

/// Protocol game modes have to conform to to use the LapSession feature.
protocol LapSessionProtocol {
    var lapSessionFeature: LapSessionFeature { get set }
}

/// Defines the duration and number of a lab. Uses the millis since the Racetrack-Microcontroller booted to calulate
/// the duration. By that, delays introduced via the BLE connection aren't transferd to the measurements.
struct Lap: Identifiable {
    let id: Int
    var startMillis: UInt32
    var endMillis: UInt32?
    
    var isFinished: Bool {
        return (endMillis != nil)
    }
    
    init(id: Int, startMillis: UInt32, endMillis: UInt32? = nil) {
        self.id = id
        self.startMillis = startMillis
        self.endMillis = endMillis
    }
    
    var durationInMillis: UInt32? {
        if (endMillis == nil) { return nil }
        return (endMillis! - startMillis)
    }
}

/// Manages the times of the laps on the specified `RaceTrackSlot`.
@Observable
class LapSessionFeature {
    
    /// The minimal duration a lap can take. Anything under that value gets treated as sensor issues or cheating by the user.
    static let minimalLapDuration = 500
    
    struct LapFinishedInfo {
        let lap: Lap
        let fastestLap: Bool
    }
    
    /// Combine publisher to track changes on the current lap.
    var onLapFinishedPublisher: AnyPublisher<LapFinishedInfo, Never> { onLapFinished.eraseToAnyPublisher() }
    private let onLapFinished = PassthroughSubject<LapFinishedInfo, Never>()
    
    /// Enables or disables the measurement of labs.
    var enabled = false {
        didSet {
            if !enabled { currentLap = nil }
        }
    }
    
    /// The slot on the RaceTrack the session applies to.
    let slot: RaceTrackSlot
    
    private(set) var laps: [Lap] = []
    private(set) var currentLap: Lap?
    
    var currentLapNumber: Int {
        return (currentLap?.id ?? 0)
    }
    
    /// The duration of all laps summed up.
    var durationOfSessionInMillis: UInt32 {
        var duration: UInt32 = 0
        laps.forEach { lap in
            duration += (lap.durationInMillis ?? 0)
        }
        return duration
    }
    
    /// The duration of the fastest lap.
    var fastestLapDuration: UInt32? {
        laps.compactMap { $0.durationInMillis }.min()
    }
    
    init(slot: RaceTrackSlot = RaceTrackSlot.defaultSlot) {
        self.slot = slot
    }
    
    func carDroveOverFinishline(_ millis: UInt32) {
        if enabled == false { return }
        
        if var currentLap = currentLap {
            currentLap.endMillis = millis
            
            // Ignores laps which are unpossible fast
            if let duration = currentLap.durationInMillis {
                if (duration < LapSessionFeature.minimalLapDuration) {
                    print("Lap with lower duration than allowed registered: \(duration)")
                    return
                }
            }
            
            laps.append(currentLap)
            
            // Inform about finished lap via publisher
            let currentLapIsFastest = (fastestLapDuration == currentLap.durationInMillis)
            let info = LapFinishedInfo(lap: currentLap, fastestLap: currentLapIsFastest)
            onLapFinished.send(info)
        }
        
        // Instantly start a new lap after one finished
        currentLap = Lap(id: (laps.count + 1), startMillis: millis)
    }
}
