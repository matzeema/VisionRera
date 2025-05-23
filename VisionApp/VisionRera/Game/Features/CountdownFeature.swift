//
//  CountdownFeature.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 23.05.25.
//

import Foundation
import Combine

protocol CountdownProtocol {
    var countdownFeature: CountdownFeature { get set }
}

@Observable
class CountdownFeature {
    static let defaultStartValue = 3
    static let defaultTimerInterval = 1.0
 
    private(set) var countdownValue = defaultStartValue
    private(set) var countdownDidFinishPublisher = PassthroughSubject<Void, Never>()

    private var timerSubscription: AnyCancellable?

    func start(
        startValue: Int = CountdownFeature.defaultStartValue,
        interval: Double = CountdownFeature.defaultTimerInterval
    ) {
        countdownValue = startValue
        timerSubscription?.cancel()

        timerSubscription = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.decreaseCountdown()
            }
    }

    func cancel() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func decreaseCountdown() {
        guard countdownValue > 0 else { return }

        countdownValue -= 1

        if countdownValue <= 0 {
            timerSubscription?.cancel()
            timerSubscription = nil
            countdownDidFinishPublisher.send()
        }
    }
}

