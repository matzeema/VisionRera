//
//  GameModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import SwiftUI

// Define features of a game modes as protocols.
enum SpeedToRacetrackState {
    case stop
    case racing(speed: Float)
}

protocol GameModeProtocol {
    var speedToRaceTrackState: SpeedToRacetrackState { get set }
}

/// Manages the state of the game.
@MainActor
@Observable
class GameModel {
    enum Mode {
        case freeDrive
        case lapsRace
    }
    var mode: Mode = .freeDrive
    
    
}
