//
//  RacetrackManager.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 24.10.24.
//

import Foundation
import CoreBluetooth



/// Manages the BLE connection and data with the RaceTrack. Call `scanForRaceTrack` to look for nearby BLE devices with the
/// required services. If there was found a device the Manager automatically connects to it and reads the data for each slot into the
/// `RaceTrackSlotData` object.
@Observable
class RaceTrackManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
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
    /// Defines the connection state between the Apple Vision and a BLE device with the required services for a RaceTrack..
    /// For information about if Bluetooth is enabled, allowed, poweredOn, etc. use the `bleState` enum.
    private(set) var connectionState = ConnectionState.notConnected
    
    private var cbCentralManager: CBCentralManager?
    private var cbPeripheral: CBPeripheral?
    
    var raceTrackSlotDataA: RaceTrackSlotData?
    var raceTrackSlotDataB: RaceTrackSlotData?
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
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
        
        raceTrackSlotDataA = RaceTrackSlotData()
        raceTrackSlotDataB = RaceTrackSlotData()
    }
    
    /// Called when failed connecting to a peripheral.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cbPeripheral = nil
        connectionState = ConnectionState.failedConnect
    }
    
    /// Called when disconnected from a peripheral.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = ConnectionState.didDisconnect
        
        raceTrackSlotDataA = nil
        raceTrackSlotDataB = nil
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
            raceTrackSlotDataA?.speedCharac = characteristic
        case RaceTrackCBUuids.speedSlotBUuid:
            raceTrackSlotDataB?.speedCharac = characteristic
            
        // Finishline sensors characteristics
        case RaceTrackCBUuids.lastTriggerFinishlineSensorAUuid:
            raceTrackSlotDataA?.lastTriggerCharac = characteristic
        case RaceTrackCBUuids.lastTriggerFinishlineSensorBUuid:
            raceTrackSlotDataB?.lastTriggerCharac = characteristic
            
        case RaceTrackCBUuids.carStandsOnSensorAUuid:
            raceTrackSlotDataA?.carStandsOnSensorCharac = characteristic
        case RaceTrackCBUuids.carStandsOnSensorBUuid:
            raceTrackSlotDataB?.carStandsOnSensorCharac = characteristic
            
        // CarOnTrack detection characteristics
        case RaceTrackCBUuids.carOnTrackStateAUuid:
            raceTrackSlotDataA?.carOnTrackCharac = characteristic
        case RaceTrackCBUuids.carOnTrackStateBUuid:
            raceTrackSlotDataB?.carOnTrackCharac = characteristic
            
        default: break
        }
    }
    
    func setSpeed(_ slot: RaceTrackSlot, speed: UInt8) {
        if let raceTrackSlotData = getRaceTrackSlotData(slot),
           let charac = raceTrackSlotData.speedCharac {
            cbPeripheral?.writeValue(Data([speed]), for: charac, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func getRaceTrackSlotData(_ slot: RaceTrackSlot) -> RaceTrackSlotData? {
        switch slot {
        case .A: return raceTrackSlotDataA
        case .B: return raceTrackSlotDataB
        }
    }

}


