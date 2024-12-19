//
//  SpeedCurves.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 19.12.24.
//

import Foundation

enum InputSpeedCurve: CaseIterable {
    case linear
    case quadEaseOut
    case quintEaseOut
    case circEaseOut
}

/// Math implementations of the speed curves.
extension InputSpeedCurve {
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
