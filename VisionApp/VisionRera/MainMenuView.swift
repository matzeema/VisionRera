//
//  MainMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        TabView {
            Tab("Start", systemImage: "play") {
                GameMenuView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.blue, .clear]), startPoint: .top, endPoint: .bottom)
                    )
                    .glassBackgroundEffect()
            }
            
            Tab("Racetrack", systemImage: "car.rear.road.lane") {
                Text("Racetrack")
            }
            .badge("")

            Tab("Controls", systemImage: "hand.wave") {
                InputMenuView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.orange, .clear]), startPoint: .top, endPoint: .bottom)
                    )
                    .glassBackgroundEffect()
                    
            }
            .badge("")


            Tab("Info", systemImage: "info.circle") {
                Text("About this app")
            }
        }
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    MainMenuView()
        .environment(ImmersiveModel())
        .environment(RaceTrackModel())
        .environment(InputModel())
}
