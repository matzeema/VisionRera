//
//  InputModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import SwiftUI
import ARKit

/// The protocol all input methods need to conform to.
protocol InputProtocol {
    var speed: Float { get set }
    var speedCurve: InputSpeedCurve { get set }
    var isAvailable: Bool { get }
}

/// The protocol hand gesture input methods need to conforn to. Uses ARKit for Handtracking.
protocol HandtrackingInputProtocol: InputProtocol {
    func update(from handAnchor: AnchorUpdate<HandAnchor>)
}

enum InputSpeedCurve: CaseIterable {
    case linear
    case quadEaseOut
    case quintEaseOut
    case circEaseOut
}

/// Manages the state of the current input method.
@MainActor
@Observable
class InputModel {
    private let handGestureInput = HandGestureInput()
    private let gamepadInput = GamepadInput()
    
    enum Method {
        case handGesture
        case gamepad
    }
    var method: Method = .handGesture
    
    private var inputHandler: any InputProtocol {
        switch method {
        case .handGesture: return handGestureInput
        case .gamepad:     return gamepadInput
        }
    }
    
    private var handtrackingHandler: (any HandtrackingInputProtocol)? {
        return inputHandler.self as? HandtrackingInputProtocol
    }
    
    var inputRequiresHandtrackingData: Bool {
        return handtrackingHandler != nil
    }
    
    /// Takes the AnchorUpdates from ARKitSessions via the HandTrackingProvider. Forwards the data
    /// to the input method if it requires handtracking data.
    func updateHandTrackingInputMethod(handAnchor: AnchorUpdate<HandAnchor>) {
        if let handtrackingHandler {
            handtrackingHandler.update(from: handAnchor)
        }
    }
    
    /// The speed the user currently inputs. Allowed range is between 0.0 and 1.0. This value can differ
    /// from the actual speed send to the RaceTrack, depending on the current state of the game.
    var speed: Float {
        let inputSpeed: Float = inputHandler.speed
        let speedWithApplyCurve = speedCurve.apply(to: inputSpeed)
        return speedWithApplyCurve
    }
    
    /// The speed curve the user selected. This curve will be applied on the input speed and allows
    /// for example to give more control in the upper or lower speed ranges.
    var speedCurve: InputSpeedCurve {
        return inputHandler.speedCurve
    }
}

/// Math implementations of the speed curves.
private extension InputSpeedCurve {
    func apply(to value: Float) -> Float {
        switch self {
        case .linear:       return value
        case .quadEaseOut:  return quadEaseOut(value)
        case .quintEaseOut: return quintEaseOut(value)
        case .circEaseOut:  return circEaseOut(value)
        }
    }
    
    private func quadEaseOut(_ p: Float) -> Float {
        return -(p * (p - 2));
    }

    private func quintEaseOut(_ p: Float) -> Float {
        return (1 - pow(1 - p, 5));
    }

    private func circEaseOut(_ p: Float) -> Float {
        return sqrt(1 - pow(p - 1, 2));
    }
}

/// Generic enum extension to cycle through cases.
extension InputSpeedCurve {
    func next() -> InputSpeedCurve {
      let allCases = Self.allCases
      guard let currentIndex = Self.allCases.firstIndex(of: self) else { return self }
      let nextIndex = (currentIndex + 1) % allCases.count
      return allCases[nextIndex]
    }
}
