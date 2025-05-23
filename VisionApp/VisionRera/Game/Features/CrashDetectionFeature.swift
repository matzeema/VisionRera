//
//  CrashDetection.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

protocol CarOnTrackStateProtocol {
    func onCarOnTrackStateChanged(state: CarOnTrackState)
}

protocol CrashDetectionProtocol {
    var crashDetectionFeature: CrashDetectionFeature { get set }
}

@Observable
class CrashDetectionFeature {
    
    /// Enables or disables the detection of crashes.
    var enabled = false
    var registerNewCrashes = true
    
    enum CrashInfo {
        case newCrash
        case dissolved
        case dissolvedCanceled
    }
    
    /// Combine publisher to track updates on the car crashes.
    var onCrashUpdatedPublisher: AnyPublisher<CrashInfo, Never> { onCrashUpdated.eraseToAnyPublisher() }
    private let onCrashUpdated = PassthroughSubject<CrashInfo, Never>()
    
    func onCarOnTrackStateChanged(state: CarOnTrackState) {
        if enabled == false { return }
        
        if registerNewCrashes {
            if state != .notOnTrack { return }
            
            onCrashUpdated.send(.newCrash)
            registerNewCrashes = false
            return
        }
        
        // We need to dissolve the crash when there is already one registerd.
        if state != .notOnTrack {
            onCrashUpdated.send(.dissolved)
        } else {
            onCrashUpdated.send(.dissolvedCanceled)
        }
    }
}
