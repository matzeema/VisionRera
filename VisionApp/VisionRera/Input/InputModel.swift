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
    func onAuthenticationChanged(status: ARKitSession.AuthorizationStatus)
    func onDataproviderStateChanged(state: DataProviderState)
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
    let handGestureInput = HandGestureInput()
    let gamepadInput = GamepadInput()
    
    enum Method: String, CaseIterable {
        case handGesture
        case gamepad
    }
    var method: Method = .handGesture
    
    var inputHandler: any InputProtocol {
        switch method {
        case .handGesture: return handGestureInput
        case .gamepad:     return gamepadInput
        }
    }
    
    var handtrackingHandler: (any HandtrackingInputProtocol)? {
        return inputHandler.self as? HandtrackingInputProtocol
    }
    
    var inputRequiresHandtrackingData: Bool {
        return handtrackingHandler != nil
    }
    
    var inputIsAvailable: Bool {
        return inputHandler.isAvailable
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

/// Get input values in a easy to display format.
extension InputModel {
    var speedFormated: String {
        return "\(String(format: "%.0f", inputHandler.speed * 100))%"
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

/// Get the descriptive names for all speed curves..
extension InputSpeedCurve {
    var description: String {
        switch self {
        case .linear:       return "Linear"
        case .quadEaseOut:  return "Quad Ease Out"
        case .quintEaseOut: return "Quint Ease Out"
        case .circEaseOut:  return "Circ Ease Out"
        }
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
