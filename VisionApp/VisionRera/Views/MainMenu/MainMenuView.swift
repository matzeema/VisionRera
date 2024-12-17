//
//  MainMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(InputModel.self) private var inputModel
    
    private var inputMethodSystemImage: String {
        switch inputModel.method {
        case .handGesture: "hand.wave"
        case .gamepad: "gamecontroller"
        }
    }
    
    var body: some View {
        TabView {
            Tab("Start", systemImage: "play") {
                GameMenuView()
                    .gradientBackground(color: .indigo)
            }
            
            Tab("Racetrack", systemImage: "car.rear.road.lane") {
                Text("Racetrack")
                    .gradientBackground(color: .purple)
            }
                
            Tab("Controls", systemImage: inputMethodSystemImage) {
                InputMenuView()
                    .gradientBackground(color: .orange)
            }
            .badge(inputModel.inputIsAvailable ? nil : Text(""))
        }
    }
}

/// Creates a gradient background starting from the top by going to clear at the bottom.
struct GradientBackgroundModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [color, .clear]), startPoint: .top, endPoint: .bottom)
            )
            .glassBackgroundEffect()
    }
}

extension View {
    func gradientBackground(color: Color) -> some View {
        self.modifier(GradientBackgroundModifier(color: color))
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    MainMenuView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
        .environment(InputModel())
}
