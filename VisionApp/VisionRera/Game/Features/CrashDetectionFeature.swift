//
//  CrashDetection.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

protocol CrashDetectionProtocol {
    var crashDetectionFeature: CrashDetectionFeature { get set }
}

@Observable
class CrashDetectionFeature {
    
    /// Enables or disables the detection of crashes.
    var enabled = false
    
    struct CrashInfo {
        // For now the crash info is just empty.
        // More info might be needed in the future.
    }
    
    /// Combine publisher to track updates on the car crashes.
    var onCarCrashedPublisher: AnyPublisher<CrashInfo, Never> { onCarCrashed.eraseToAnyPublisher() }
    private let onCarCrashed = PassthroughSubject<CrashInfo, Never>()
    
    func onCarOnTrackStateChanged(state: CarOnTrackState) {
        if state == .notOnTrack {
            onCarCrashed.send(CrashInfo())
        }
    }
}
