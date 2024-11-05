//
//  LaunchView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 24.10.24.
//

import SwiftUI
import CoreBluetooth

/// Welcomes the user with the app title and informs about the connection with the RaceTrack and the ImmersiveSpace.
struct WelcomeView: View {
    @Environment(ImmersiveModel.self) private var immersiveModel
    @Environment(RaceTrackModel.self) private var raceTrackModel
    
    var body: some View {
        VStack {
            VStack {
                Text("VisionRera")
                    .font(.extraLargeTitle2)
                Text("Vision Pro x Carrera Experience")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }.padding()
            
            if raceTrackModel.bleState != .poweredOn {
                BLEInfoView()
                
            } else if raceTrackModel.connectionState != .connected {
                RaceTrackConnectionView()
                
            } else if immersiveModel.immersiveSpaceState != .open {
                ImmersiveSpaceInfoView()
            }
        }
        .padding()
    }
}

/// Informs the user about issues with the BLE connection. Is empty if there are no issues.
private struct BLEInfoView: View {
    @Environment(RaceTrackModel.self) var raceTrackModel
    
    var body: some View {
        switch raceTrackModel.bleState {
        case .unauthorized:
            SetupInfoView(
                icon: Image(systemName: "hand.raised")
                    .symbolEffect(.wiggle, options: .repeat(3)),
                title: "Bluetooth not authorized",
                description: "Go to Settings > Privacy > Bluetooth and enable VisionRera."
            )
            
        case .resetting:
            SetupInfoView(
                icon: Image(systemName: "wave.3.right.circle")
                    .symbolEffect(.pulse),
                title: "Bluetooth is resetting",
                description: "Bluetooth is temporarily unavailable."
            )
        case .poweredOff:
            SetupInfoView(
                icon: Image(systemName: "wave.3.right.circle"),
                title: "Bluetooth disabled",
                description: "Turn on Bluetooth to use VisionRera."
            )
            
        case .poweredOn:
            HStack { } // Show nothing if there is no issue
            
        default:
            SetupInfoView(
                icon: Image(systemName: "vision.pro.slash"),
                title: "Bluetooth unavailable",
                description: "Bluetooth is not supported on this device."
            )
        }

    }
}

/// Informs the user about the connection state with the RaceTrack. Is empty if the connection was successful.
private struct RaceTrackConnectionView: View {
    @Environment(RaceTrackModel.self) var raceTrackModel
    
    var body: some View {
        switch raceTrackModel.connectionState {
        case .notConnected:
            ScanForRaceTrackButtonView(title: "Scan for Racetrack")
            
        case .scanning:
            SetupInfoView(
                icon: Image(systemName: "car.front.waves.down")
                    .symbolEffect(.variableColor),
                title: "Scanning...",
                description: "Searching for nearby RaceTracks."
            )

        case .tryConnect:
            SetupInfoView(
                icon: Image(systemName: "car.front.waves.down")
                    .symbolEffect(.variableColor),
                title: "RaceTrack found",
                description: "Trying to connect..."
            )
            
        case .failedConnect:
            VStack {
                ScanForRaceTrackButtonView(title: "Rescan for RaceTrack")
                SetupInfoView(
                    icon: Image(systemName: "exclamationmark.circle"),
                    title: "Failed",
                    description: "Something went wrong while connecting."
                )
            }
            
        case .didDisconnect:
            VStack {
                ScanForRaceTrackButtonView(title: "Rescan for RaceTrack")
                SetupInfoView(
                    icon: Image(systemName: "exclamationmark.circle"),
                    title: "Disconnected",
                    description: "Connection with the RaceTrack was closed."
                )
            }
            
        case .connected:
            HStack { } // Show nothing if connection was successfull
        }
    }
}

/// Button to let the user scan for a nearby RaceTrack.
private struct ScanForRaceTrackButtonView: View {
    @Environment(RaceTrackModel.self) var raceTrackModel
    let title: String
    
    var body: some View {
        Button(
            action: { raceTrackModel.scanForRaceTrack() },
            label: {
                HStack {
                    Image(systemName: "car.front.waves.down")
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 10.0)))
                    Text(title)
                }
            }
        )
        .padding(.bottom)
    }
}

private struct ImmersiveSpaceInfoView: View {
    @Environment(ImmersiveModel.self) private var immersiveModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some View {
        VStack {
            Button(
                action: {
                    Task { @MainActor in
                        immersiveModel.immersiveSpaceState = .inTransition
                        switch await openImmersiveSpace(id: immersiveModel.immersiveSpaceID) {
                        case .opened:
                            // Don't set immersiveSpaceState to .open because there
                            // may be multiple paths to ImmersiveView.onAppear().
                            // Only set .open in ImmersiveView.onAppear().
                            break
                            
                        case .userCancelled, .error:
                            // On error, we need to mark the immersive space
                            // as closed because it failed to open.
                            fallthrough
                        @unknown default:
                            // On unknown response, assume space did not open.
                            immersiveModel.immersiveSpaceState = .closed
                        }
                        
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "car.rear.road.lane")
                            .symbolEffect(.breathe, options: .repeat(.periodic(delay: 10.0)))
                        Text("Launch the Experience")
                    }
                }
            )
            .disabled(immersiveModel.immersiveSpaceState == .inTransition)
            
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
                    .imageScale(.small)
                Text("RaceTrack connected")
                    .font(.callout)
            }
            .padding(.top, 4.0)
        }
    }
}

/// Generic view to inform the user about issues with BLE and the RaceTrack.
private struct SetupInfoView<Icon: View>: View {
    var icon: Icon
    let title: String
    let description: String
    
    var body: some View {
        GroupBox {
            VStack {
                icon
                    .padding(.trailing, 8.0)
                    .imageScale(.large)
                
                VStack {
                    Text(title)
                        .font(.headline)
                    Text(description)
                }
                .multilineTextAlignment(.center)
                .padding(4.0)
            }
            .frame(width: 400)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    WelcomeView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
}
