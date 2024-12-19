//
//  GradientBackgroundModifier.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 19.12.24.
//

import SwiftUI

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
