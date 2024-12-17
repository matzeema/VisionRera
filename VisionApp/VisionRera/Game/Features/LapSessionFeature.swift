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
struct Lap {
    let lapNumber: Int
    var startMillis: UInt32
    var endMillis: UInt32?
    
    var isFinished: Bool {
        return (endMillis != nil)
    }
    
    init(lapNumber: Int, startMillis: UInt32, endMillis: UInt32? = nil) {
        self.lapNumber = lapNumber
        self.startMillis = startMillis
        self.endMillis = endMillis
    }
    
    var durationInMillis: UInt32? {
        if (endMillis == nil) { return nil }
        return (endMillis! - startMillis)
    }
}

/// Manages the times of the laps on the specified `RaceTrackSlot`.
class LapSessionFeature {
    
    /// The minimal duration a lap can take. Anything under that value gets treated as sensor issues or cheating by the user.
    static let minimalLapDuration = 500
    
    /// Combine publisher to track changes on the current lap.
    var onLapFinishedPublisher: AnyPublisher<Lap, Never> { onLapFinished.eraseToAnyPublisher() }
    private let onLapFinished = PassthroughSubject<Lap, Never>()
    
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
        return (currentLap?.lapNumber ?? 0)
    }
    
    /// The duration of all laps summed up.
    var durationOfSessionInMillis: UInt32 {
        var duration: UInt32 = 0
        laps.forEach { lap in
            duration += (lap.durationInMillis ?? 0)
        }
        return duration
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
            onLapFinished.send(currentLap)
        }
        
        // Instantly start a new lap after one finished
        currentLap = Lap(lapNumber: (laps.count + 1), startMillis: millis)
    }
}
