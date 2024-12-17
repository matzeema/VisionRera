//
//  GameModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import Foundation
import SwiftUI

/// The protocol every game mode has to conform to. Provides default options like
/// the current speed state.
protocol GameModeProtocol {
    var speedToRaceTrack: Float { get set }
    
    func onSpeedInputChanged(speed: Float)
}

/// Manages the state of the game.
@MainActor
@Observable
class GameModel {
    private(set) var gameModeHandler: (any GameModeProtocol)?
    
    enum Mode: String, CaseIterable {
        case freeDrive
        case lapsRace
    }
    
    var mode: Mode? = nil {
        didSet {
            switch mode {
            case nil: gameModeHandler = nil
            case .freeDrive: gameModeHandler = FreeDriveMode()
            case .lapsRace:  gameModeHandler = LapsRaceMode()
            }
        }
    }
    
    var lapSessionFeature: LapSessionProtocol? {
        gameModeHandler as? LapSessionProtocol
    }
}

/// Gives metadata about the GameModes like the name and description of the mode.
extension GameModel.Mode {
    struct Metadata {
        let name: String
        let description: String
    }
    
    var metadata: Metadata {
        switch self {
            case .freeDrive: return Metadata(name: "Free Drive", description: "Drive around the track")
            case .lapsRace:  return Metadata(name: "Laps Race", description: "Race around the track")
        }
    }
}
