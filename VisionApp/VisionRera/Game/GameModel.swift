//
//  GameModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import SwiftUI

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
    private var gameModel: GameModeProtocol?
    
    enum Mode {
        case freeDrive
        case lapsRace
    }
    var mode: Mode = .freeDrive
    
    
}
