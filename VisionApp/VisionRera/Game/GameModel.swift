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
    
    enum Mode {
        case none
        case freeDrive
        case lapsRace
    }
    var mode: Mode = .none {
        didSet {
            switch mode {
            case .none:      gameModeHandler = nil
            case .freeDrive: gameModeHandler = FreeDriveMode()
            case .lapsRace:  gameModeHandler = LapsRaceMode()
            }
        }
    }
    
    private(set) var gameModeHandler: (any GameModeProtocol)?
    
    var lapSessionFeature: LapSessionProtocol? {
        gameModeHandler as? LapSessionProtocol
    }
    
}
