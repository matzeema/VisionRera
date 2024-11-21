//
//  GameMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI

struct GameMenuView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 8.0) {
                GameItemView(
                    gameItemViewModel: GameItemViewModel(
                        name: "Rundenrennen",
                        description: "Drive multiple laps around the track.",
                        backgroundColor: .blue)
                )
                .padding(.bottom, 16.0)
                GameItemView(gameItemViewModel: GameItemViewModel(
                    name: "Free Race",
                    description: "Get rolling with no restrictions.",
                    backgroundColor: .green))
            }
            .padding(32.0)
        }
    }
}

struct GameItemViewModel {
    let name: String
    let description: String
    let backgroundColor: Color
}

private struct GameItemView: View {
    let gameItemViewModel: GameItemViewModel
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text(gameItemViewModel.name)
                        .font(.title)
                    Text(gameItemViewModel.description)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                Button(action: {}, label: {
                    Text("Start")
                })
            }
            .padding(8.0)
            .frame(width: 500, alignment: .leading)

        }
        .hoverEffect()
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    GameMenuView()
        .environment(RaceTrackModel())
        
}
