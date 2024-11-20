//
//  GamepadInput.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import SwiftUI

@Observable
class GamepadInput: InputProtocol {
    var speed: Float = 0
    var speedCurve: InputSpeedCurve = .linear
    
    // TODO: Implement Gamepad support
}
