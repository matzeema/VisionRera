//
//  RaceTackConstants.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 24.10.24.
//

import CoreBluetooth

/// Holds all CBUuids for the BLE data.
struct RaceTrackCBUuids {
    private init() {}
    
    // Speed service
    static let speedServiceUuid = CBUUID(string: "0x3940")
    static let speedSlotAUuid   = CBUUID(string: "0x3941")
    static let speedSlotBUuid   = CBUUID(string: "0x3942")
    
    // Finishline sensor service
    static let finishlineSensorServiceUuid      = CBUUID(string: "0x3740")
    static let lastTriggerFinishlineSensorAUuid = CBUUID(string: "0x3741")
    static let lastTriggerFinishlineSensorBUuid = CBUUID(string: "0x3742")
    static let carStandsOnSensorAUuid           = CBUUID(string: "0x3743")
    static let carStandsOnSensorBUuid           = CBUUID(string: "0x3744")
    
    // CarOnTrack detection service
    static let carOnTrackServiceUuid = CBUUID(string: "0x3840")
    static let carOnTrackStateAUuid  = CBUUID(string: "0x3841")
    static let carOnTrackStateBUuid  = CBUUID(string: "0x3842")
}

