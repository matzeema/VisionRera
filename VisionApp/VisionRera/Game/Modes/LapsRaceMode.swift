//
//  LapsRaceMode.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 27.11.24.
//

import Foundation
import Combine

@Observable
class LapsRaceMode: GameModeProtocol,
                    LapSessionProtocol,
                    CrashDetectionProtocol,
                    CarAtStartlineProtocol,
                    CountdownProtocol {
    
    static let lapsCount: Int = 3
    
    var speedToRaceTrack: Float = 0
    var lapSessionFeature = LapSessionFeature()
    var crashDetectionFeature = CrashDetectionFeature()
    var countdownFeature = CountdownFeature()
    
    private var onLapFinishedSubscription: AnyCancellable?
    private var onCarCrashSubscription: AnyCancellable?
    private var countdownSubscription: AnyCancellable?
    
    init() {
        onLapFinishedSubscription = lapSessionFeature.onLapFinishedPublisher.sink { [weak self] lapInfo in
            self?.onLapFinished(lap: lapInfo.lap)
        }
        onCarCrashSubscription = crashDetectionFeature.onCrashUpdatedPublisher.sink { [weak self] crashInfo in
            self?.onCrashUpdated(info: crashInfo)
        }
        countdownSubscription = countdownFeature.countdownDidFinishPublisher.sink { [weak self] _ in
            self?.onCountdownFinished()
        }
    }
    
    enum State {
        case waitForCarPlaceAtStartline
        case raceStartCountdown
        case racing
        case carCrash
        case restartCountdown
        case finishedRace
    }
    
    private(set) var state = State.waitForCarPlaceAtStartline {
        didSet {
            if state == oldValue { return }
            
            // Reset the speed if not racing.
            switch state {
            case .racing: break
            default:      speedToRaceTrack = 0.0
            }
        }
    }
    
    private(set) var crashes = 0
    
    func onSpeedInputChanged(speed: Float) {
        print("Speed Input changed: \(speed)")
        switch state {
        case .racing: speedToRaceTrack = speed
        default:      break
        }
    }
    
    func carStandsAtStartline(_ isAtStart: Bool) {
        switch state {
        case .waitForCarPlaceAtStartline:
            if isAtStart {
                countdownFeature.start()
                state = .raceStartCountdown
            }
            
        case .raceStartCountdown:
            if !isAtStart {
                countdownFeature.cancel()
                state = .waitForCarPlaceAtStartline
            }
            
        default: break
        }
    }
    
    private func onCountdownFinished() {
        switch state {
        case .raceStartCountdown:
            crashDetectionFeature.enabled = true
            fallthrough
            
        case .restartCountdown:
            lapSessionFeature.enabled = true
            state = .racing
            
        default: break
        }
    }
    
    private func onCrashUpdated(info: CrashDetectionFeature.CrashInfo) {
        switch info {
        case .newCrash:
            crashes += 1
            lapSessionFeature.enabled = false
            state = .carCrash
            
        case .dissolved:
            state = .restartCountdown
            countdownFeature.start()
            
        case .dissolvedCanceled:
            state = .carCrash
            countdownFeature.cancel()
        }
    }
    
    private func onLapFinished(lap: Lap) {
        if state != .racing { return }
        if lapSessionFeature.laps.count < LapsRaceMode.lapsCount { return }
        
        onRaceFinished()
    }
    
    private func onRaceFinished() {
        state = .finishedRace
        lapSessionFeature.enabled = false
        crashDetectionFeature.enabled = false
        countdownFeature.cancel()
    }
}
