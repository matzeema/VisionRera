//
//  RaceTrackSlot.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 24.10.24.
//
import CoreBluetooth

enum RaceTrackSlot: UInt8 {
    case A
    case B
}

enum CarOnTrackState: UInt8 {
    case notOnTrack = 0
    case onTrackNotDriving = 1
    case onTrackDriving = 2

}

/// Contains all information regarding one slot, including the BLE charaterisitcs.
struct RaceTrackSlotData {
    var speedCharac: CBCharacteristic?
    var lastTriggerCharac: CBCharacteristic?
    var carStandsOnSensorCharac: CBCharacteristic?
    var carOnTrackCharac: CBCharacteristic?
    
    // TODO: Add getter for speed
    
    var lastTriggerFinishlineSensor: UInt32? {
        guard let lastTriggerCharac else { return nil }
        guard let millis = convertDataToUInt32(data: lastTriggerCharac.value ?? Data()) else { return nil }
        return millis
    }
    
    var carStandsOnSensor: Bool {
        guard let carStandsOnSensorCharac else { return false }
        return (carStandsOnSensorCharac.value?[0] ?? 0) > 0
    }
    
    var carOnTrackState: CarOnTrackState? {
        guard let carOnTrackCharac else { return nil }
        guard let rawValue = carOnTrackCharac.value?[0] else { return nil }
        guard let state = CarOnTrackState(rawValue: rawValue) else { return nil }
        return state
    }
}


extension RaceTrackSlotData {
    
    /// Helps converting `Data` objects to `UInt32` values.
    private func convertDataToUInt32(data: Data) -> UInt32? {
        if (data.isEmpty) { return nil }
        let value =
          (UInt32(data[0]) << (0*8)) |
          (UInt32(data[1]) << (1*8)) |
          (UInt32(data[2]) << (2*8)) |
          (UInt32(data[3]) << (3*8))
        return value
    }
}
