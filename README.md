# VisionRera

A **visionOS application** for controlling slot car race tracks using Apple Vision Pro. Built with SwiftUI and RealityKit, this app provides an immersive racing experience with hand gesture and gamepad controls.

## 🎮 Features

- **Immersive Mixed Reality**: Race control interface in visionOS immersive space
- **Multiple Input Methods**: 
  - Hand gesture tracking for intuitive speed control
  - Gamepad support for traditional gaming experience
- **Bluetooth Low Energy (BLE)**: Real-time communication with custom Arduino-based race track hardware
- **Track Detection**: Automatically detect and configure race track setup
- **Race Modes**: Time trials and competitive racing with finish line detection
- **Live Telemetry**: Real-time speed visualization and lap timing

## 🛠️ Technology Stack

- **visionOS** - Apple Vision Pro platform
- **SwiftUI** - Modern declarative UI framework
- **RealityKit** - 3D rendering and spatial computing
- **ARKit** - Hand tracking and spatial anchors
- **CoreBluetooth** - BLE communication with hardware
- **GameController** - Gamepad input support

## 📋 Requirements

- Apple Vision Pro
- Xcode 15.0+
- Custom Arduino-based slot car track with BLE controller (hardware schematics included in `ControlCircuitBoard.fzz`)

## ⚠️ Project Status

This project is **not in a release state** and is primarily shared for portfolio purposes. The Arduino firmware that handles BLE commands on the hardware side is part of a separate private project and is not included in this repository.

## 🔧 Hardware Setup

The included Fritzing file (`ControlCircuitBoard.fzz`) contains the circuit design for the Arduino-based race track controller. The hardware setup requires:
- Arduino board with BLE capability
- Motor controllers for slot car tracks
- Finish line sensors
- Track detection sensors

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Created by Mattias Emanuel as a portfolio project demonstrating visionOS development, spatial computing, and hardware integration.*
