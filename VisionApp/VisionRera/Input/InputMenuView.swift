//
//  InputMenuView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 21.11.24.
//

import SwiftUI
import ARKit

struct InputMenuView: View {
    @Environment(InputModel.self) private var inputModel
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Selected input method
                HStack(spacing: 24.0) {
                    InputMethodView(.handGesture)
                    InputMethodView(.gamepad)
                }
                .padding(.bottom, 24.0)
                
                switch inputModel.method {
                case .handGesture: HandGestureOptionsView()
                case .gamepad: GamepadOptionsView()
                }
            }
            .padding(32)
        }
    }
}

private struct InputMethodView: View {
    @Environment(InputModel.self) private var inputModel
    
    let inputMethod: InputModel.Method
    let imageSystemName: String
    let title: String
    
    init(_ inputMethod: InputModel.Method) {
        self.inputMethod = inputMethod
        
        switch inputMethod {
        case .handGesture:
            imageSystemName = "hand.wave.fill"
            title = "Handgesture"
        case .gamepad:
            imageSystemName = "gamecontroller.fill"
            title = "Gamecontroller"
        }
    }
    
    var selected: Bool {
        inputMethod == inputModel.method
    }
    
    func selectMethodAction() {
        withAnimation(.smooth) {
            inputModel.method = inputMethod
        }
    }
    
    var body: some View {
        GroupBox {
            VStack {
                Image(systemName: imageSystemName)
                    .imageScale(.large)
                VStack {
                    Text(title)
                        .font(.headline)
                    if selected {
                        Text("SELECTED")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(4.0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
        .backgroundStyle(selected ? .white.opacity(0.25) : .white.opacity(0.15))
        .scaleEffect(selected ? 1.0 : 0.8)
        .hoverEffect()
        .onTapGesture(perform: selectMethodAction)
    }
}

private struct HandGestureOptionsView: View {
    
    var body: some View {
        Text("Handgesture")
    }
}

private struct GamepadOptionsView: View {
    var body: some View {
        Text("Gamepad")
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    InputMenuView()
        .environment(InputModel())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [.orange, .clear]), startPoint: .top, endPoint: .bottom)
        )
        .glassBackgroundEffect()
}
