//
//  IssueWithInputMethodView.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 19.12.24.
//

import SwiftUI

/// View which allows to inform the user about various updates like current input issues.
/// Contains of a larage sytem icon and a title with a description text. Allows for an
/// optional button with an action.
struct InfoGroupBox: View {
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
