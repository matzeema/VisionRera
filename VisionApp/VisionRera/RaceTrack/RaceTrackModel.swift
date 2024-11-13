//
//  RaceTrackModel.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 24.10.24.
//

import Foundation
import CoreBluetooth

enum RaceTrackSlot: UInt8 {
    case A = 0
    case B = 1
    
    static var defaultSlot: RaceTrackSlot { .A }
}

enum CarOnTrackState: UInt8 {
    case notOnTrack = 0
    case onTrackNotDriving = 1
    case onTrackDriving = 2
}

/// Manages the BLE connection and data with the RaceTrack. Call `scanForRaceTrack` to look for nearby BLE devices with the
/// required services. If there was found a device the Apple Vision automatically connects to it and reads the data for each slot into the
/// `RaceTrackSlotData` object.
@Observable
class RaceTrackModel : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /// Gives information about the state of BLE on the device. Check `CBManagerState` for more details.
    private(set) var bleState = CBManagerState.unknown
    
    enum ConnectionState {
        case notConnected
        case scanning
        case tryConnect
        case failedConnect
        case connected
        case didDisconnect
    }
    /// Defines the connection state between the Apple Vision and a BLE device with the required services for a RaceTrack.
    /// For information about if Bluetooth is enabled, allowed, poweredOn, etc. use the `bleState` enum.
    private(set) var connectionState = ConnectionState.notConnected
    
    private var cbCentralManager: CBCentralManager?
    private var cbPeripheral: CBPeripheral?
    
    /// Contains the BLE charaterisitcs for one slot.
    private struct SlotCharacteristics {
        var speedCharac: CBCharacteristic?
        var lastTriggerCharac: CBCharacteristic?
        var carStandsOnSensorCharac: CBCharacteristic?
        var carOnTrackCharac: CBCharacteristic?
    }
    private var raceTrackSlotCharacsA: SlotCharacteristics?
    private var raceTrackSlotCharacsB: SlotCharacteristics?
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - BLE Delegates
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bleState = central.state
        
        switch bleState {
        case .resetting, .unsupported, .unauthorized, .poweredOff:
            connectionState = .notConnected
        default: break
        }
    }
    
    /// Starts searching for the racetrack microcontroller with the required services. If there was detected a peripheral the `didDiscover`-delegate function is called.
    func scanForRaceTrack() {
        connectionState = ConnectionState.scanning
        cbCentralManager?.scanForPeripherals(withServices: [
            RaceTrackCBUuids.speedServiceUuid,
            RaceTrackCBUuids.finishlineSensorServiceUuid,
            RaceTrackCBUuids.carOnTrackServiceUuid
        ])
    }
    
    /// Called when the scan detected a new peripheral device.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        cbCentralManager?.stopScan()
        connectionState = ConnectionState.tryConnect
        
        cbPeripheral = peripheral
        central.connect(peripheral)
    }
    
    /// Called when connected to a peripheral. Starts discovering peripheral services.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = ConnectionState.connected
        
        cbPeripheral?.delegate = self
        cbPeripheral?.discoverServices([
            RaceTrackCBUuids.speedServiceUuid,
            RaceTrackCBUuids.finishlineSensorServiceUuid,
            RaceTrackCBUuids.carOnTrackServiceUuid
        ])
        
        raceTrackSlotCharacsA = SlotCharacteristics()
        raceTrackSlotCharacsB = SlotCharacteristics()
    }
    
    /// Called when failed connecting to a peripheral.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cbPeripheral = nil
        connectionState = ConnectionState.failedConnect
    }
    
    /// Called when disconnected from a peripheral.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = ConnectionState.didDisconnect
        
        raceTrackSlotCharacsA = nil
        raceTrackSlotCharacsB = nil
        cbPeripheral = nil
    }
    
    /// Called when a peripheral discoverd services. For each detected service all required characteristics will be discoverd.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach {service in
            switch service.uuid {
                
            case RaceTrackCBUuids.speedServiceUuid:
                peripheral.discoverCharacteristics([
                    RaceTrackCBUuids.speedSlotAUuid,
                    RaceTrackCBUuids.speedSlotBUuid
                ], for: service)
                
            case RaceTrackCBUuids.carOnTrackServiceUuid:
                peripheral.discoverCharacteristics([
                    RaceTrackCBUuids.carOnTrackStateAUuid,
                    RaceTrackCBUuids.carOnTrackStateBUuid
                ], for: service)
                
            case RaceTrackCBUuids.finishlineSensorServiceUuid:
                peripheral.discoverCharacteristics([
                    RaceTrackCBUuids.lastTriggerFinishlineSensorAUuid,
                    RaceTrackCBUuids.lastTriggerFinishlineSensorBUuid,
                    RaceTrackCBUuids.carStandsOnSensorAUuid,
                    RaceTrackCBUuids.carStandsOnSensorBUuid
                ], for: service)
                
            default:
                break
            }
        }
    }
    
    /// Called when there are discoverd characteristics for a service. For each characteristic the current value will be read. If the read has finished
    /// the `didUpdateValueFor`-delegate function will be called. For specific values update notifications will be enabled. If one of these
    /// values changes the `didUpdateValueFor`-delegate function will be called aswell.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            switch characteristic.uuid {
            case RaceTrackCBUuids.lastTriggerFinishlineSensorAUuid: peripheral.setNotifyValue(true, for: characteristic)
            case RaceTrackCBUuids.lastTriggerFinishlineSensorBUuid: peripheral.setNotifyValue(true, for: characteristic)
            case RaceTrackCBUuids.carStandsOnSensorAUuid:           peripheral.setNotifyValue(true, for: characteristic)
            case RaceTrackCBUuids.carStandsOnSensorBUuid:           peripheral.setNotifyValue(true, for: characteristic)
            case RaceTrackCBUuids.carOnTrackStateAUuid:             peripheral.setNotifyValue(true, for: characteristic)
            case RaceTrackCBUuids.carOnTrackStateBUuid:             peripheral.setNotifyValue(true, for: characteristic)
            default: break
            }
            
            peripheral.readValue(for: characteristic)
        }
    }
    
    /// Called when the value of a characteristic was read or updated. Characteristics will be overriden the in the corresponding `RaceTrackSlotData` object.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print(error.debugDescription)
            return
        }
        
        switch characteristic.uuid {
            
        // Speed characteristics
        case RaceTrackCBUuids.speedSlotAUuid:
            raceTrackSlotCharacsA?.speedCharac = characteristic
        case RaceTrackCBUuids.speedSlotBUuid:
            raceTrackSlotCharacsB?.speedCharac = characteristic
            
        // Finishline sensors characteristics
        case RaceTrackCBUuids.lastTriggerFinishlineSensorAUuid:
            raceTrackSlotCharacsA?.lastTriggerCharac = characteristic
        case RaceTrackCBUuids.lastTriggerFinishlineSensorBUuid:
            raceTrackSlotCharacsB?.lastTriggerCharac = characteristic
            
        case RaceTrackCBUuids.carStandsOnSensorAUuid:
            raceTrackSlotCharacsA?.carStandsOnSensorCharac = characteristic
        case RaceTrackCBUuids.carStandsOnSensorBUuid:
            raceTrackSlotCharacsB?.carStandsOnSensorCharac = characteristic
            
        // CarOnTrack detection characteristics
        case RaceTrackCBUuids.carOnTrackStateAUuid:
            raceTrackSlotCharacsA?.carOnTrackCharac = characteristic
        case RaceTrackCBUuids.carOnTrackStateBUuid:
            raceTrackSlotCharacsB?.carOnTrackCharac = characteristic
            
        default: break
        }
    }
    
    // MARK: - Getter/Setter for slot data
    
    func setSpeed(slot: RaceTrackSlot = .defaultSlot, speed: UInt8) {
        if let raceTrackSlotData = getRaceTrackSlotCharacs(slot),
           let charac = raceTrackSlotData.speedCharac {
            cbPeripheral?.writeValue(Data([speed]), for: charac, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func getLastTriggerFinishlineSensor(slot: RaceTrackSlot = .defaultSlot) -> UInt32? {
        guard let raceTrackSlotData = getRaceTrackSlotCharacs(slot),
              let lastTriggerCharac = raceTrackSlotData.lastTriggerCharac,
              let millis = convertDataToUInt32(data: lastTriggerCharac.value ?? Data()) else { return nil }
        return millis
    }
    
    func getCarStandsOnSensor(slot: RaceTrackSlot = .defaultSlot) -> Bool {
        guard let raceTrackSlotData = getRaceTrackSlotCharacs(slot),
              let carStandsOnSensorCharac = raceTrackSlotData.carStandsOnSensorCharac else { return false }
        
        let rawValue = (carStandsOnSensorCharac.value?[0] ?? 0)
        return (rawValue > 0)
    }
    
    func getCarOnTrackState(slot: RaceTrackSlot = .defaultSlot) -> CarOnTrackState? {
        guard let raceTrackSlotData = getRaceTrackSlotCharacs(slot),
              let carOnTrackCharac = raceTrackSlotData.carOnTrackCharac,
              let rawValue = carOnTrackCharac.value?[0],
              let state = CarOnTrackState(rawValue: rawValue) else { return nil }
        return state
    }
    
    private func getRaceTrackSlotCharacs(_ slot: RaceTrackSlot) -> SlotCharacteristics? {
        switch slot {
        case .A: return raceTrackSlotCharacsA
        case .B: return raceTrackSlotCharacsB
        }
    }
}

extension RaceTrackModel {
    
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
