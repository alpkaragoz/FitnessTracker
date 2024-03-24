//
//  TextModifier.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 11.12.2023.
//

import SwiftUI

struct TextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .autocorrectionDisabled()
            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            .overlay(Capsule()
                .stroke(LinearGradient(colors: buttonGradientColors,
                                       startPoint: .leading, endPoint: .trailing), lineWidth: 5))
    }

    private var buttonGradientColors: [Color] {
        if colorScheme == .dark {
            return [.indigo, .pink]
        } else {
            return [.accentColor, .green]
        }
    }
}
