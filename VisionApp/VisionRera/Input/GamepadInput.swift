//
//  GamepadInput.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 05.11.24.
//

import SwiftUI
import Foundation
import GameController

/// Handles inputs from Gamepads.
// TODO: There is currently an issue if there are more Gamepads connected than defined in the `countOfGamepads` constant. If you connect Gamepads after the value `countOfGamepads` is reached, those Gamepads will be unable to be used, even if other Gamepads are dissconected after.
@Observable
class GamepadInput: InputProtocol {
    static let countOfGamepads = 1
    
    var speed: Float = 0
    var speedCurve: InputSpeedCurve = .linear
    
    private let notificationCenter = NotificationCenter.default

    var gcControllers = [GCController?](repeating: nil, count: GamepadInput.countOfGamepads)
    
    init() {
        notificationCenter.addObserver(
                self,
                selector: #selector(self.handleControllerDidConnect),
                name: NSNotification.Name.GCControllerDidConnect,
                object: nil
        )
        
        notificationCenter.addObserver(
                self,
                selector: #selector(self.handelControllerDisconnect(_:)),
                name: NSNotification.Name.GCControllerDidDisconnect,
                object: nil
        )
    }
    
    @objc private func handleControllerDidConnect(_ notification: Notification) {
        // Ignore controller when there are already enough controllers connected
        if (gcControllers.contains(nil) == false) { return }
        
        // Ignore notification if gamepad is no extended gamepad.
        guard let notificationData = notification.object else { return }
        guard let gcController = (notificationData as? GCController) else { return }
        guard let gamepad = gcController.extendedGamepad else { return }
        
        // Check which controller index is currently unused
        guard let arrayIndex = gcControllers.firstIndex(where: { a in a == nil }) else { return }
        gcControllers[arrayIndex] = gcController
        
        // Set the player index
        if let playerIndex = GCControllerPlayerIndex.init(rawValue: arrayIndex) {
            gcController.playerIndex = playerIndex
        }
        
        print("Game Controller connected.")
        print(gcControllers.description)
        
        // Setup controller button handelings
        weak var weakController = self

        gamepad.rightTrigger.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else { return }
            
            print(value)
            strongController.speed = value
        }
        
        gamepad.buttonX.pressedChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else { return }
            
            if (pressed) {
                strongController.speedCurve = strongController.speedCurve.next()
            }
        }
    }
    
    @objc private func handelControllerDisconnect(_ notification: Notification) {
        guard let notificationData = notification.object else { return }
        guard let gcController = (notificationData as? GCController) else { return }
        
        guard let index = gcControllers.firstIndex(where: { controller in
            return (controller == gcController)
        }) else { return }
        
        gcControllers[index] = nil
        
        print("GameController disconnect!")
        print(gcControllers.description)
    }
}

extension NSNotification.Name {
    static let onGamepadRightTriggerChanged = NSNotification.Name("Gamepads.rightTriggerChanged")
    static let onGamepadLeftTriggerChanged = NSNotification.Name("Gamepads.leftTriggerChanged")
    static let onGamepadButtonXPressed = NSNotification.Name("Gamepads.buttonXPressed")
    static let onGamepadButtonAPressed = NSNotification.Name("Gamepads.buttonAPressed")
}
