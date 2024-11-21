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
                
                // Input method options
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
    @Environment(InputModel.self) private var inputModel
    @Environment(ImmersiveModel.self) private var immersiveModel
    
    var body: some View {
        @Bindable var handGestureInput: HandGestureInput = inputModel.handGestureInput
        
        VStack {
            
            // Inform about possible issues
            if !handGestureInput.isAvailable {
                switch handGestureInput.state {
                case .authenticationNotAllowed:
                    IssueWithInputMethodView(
                        systemImageName: "hand.raised",
                        title: "Allow hand tracking",
                        description: "Go to settings and allow Worldsensing for VisionRera."
                    )
                case .handtrackingUnavailable:
                    IssueWithInputMethodView(
                        systemImageName: "vision.pro.badge.exclamationmark",
                        title: "Handtracking stopped",
                        description: "The device cannot track your hands.",
                        action: {
                            Task { await immersiveModel.tryRerunARKitSession() }
                        },
                        actionTitle: "Try again"
                    )
                    
                default: EmptyView()
                }
            }
            
            // Options
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hands")
                            .font(.headline)
                        Text("Choose the handside to control the speed.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8.0)
                    Spacer()
                    Picker("Handposition", selection: $handGestureInput.chirality) {
                        Text("Left").tag(HandAnchor.Chirality.left)
                        Text("Right").tag(HandAnchor.Chirality.right)
                    }
                }
            }
        }
    }
}

private struct GamepadOptionsView: View {
    var body: some View {
        Text("Gamepad")
    }
}

private struct IssueWithInputMethodView: View {
    let systemImageName: String
    let title: String
    let description: String
    
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(systemImageName: String, title: String, description: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        self.systemImageName = systemImageName
        self.title = title
        self.description = description
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: systemImageName)
                    .imageScale(.large)
                    .padding(.horizontal, 8.0)

                VStack(alignment: .leading) {
                    Text(title).font(.headline)
                    Text(description)
                }
                
                if let action, let actionTitle {
                    Spacer()
                    Button(actionTitle, action: action)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 600, height: 400)) {
    InputMenuView()
        .environment(InputModel())
        .environment(ImmersiveModel())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [.orange, .clear]), startPoint: .top, endPoint: .bottom)
        )
        .glassBackgroundEffect()
}
