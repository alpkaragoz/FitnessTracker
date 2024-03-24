//
//  ButtonDS.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 9.12.2023.
//

import SwiftUI

struct ButtonDesign: View {
    @Environment(\.colorScheme) var colorScheme
    private let buttonTitle: String
    private let action: () -> Void

    init(
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {
        Button(
            action: action
        ) {
            Text(buttonTitle)
                .bold()
                .foregroundColor(.white)
                .frame(width: 100, height: 40)
                .background(LinearGradient(colors: buttonGradientColors, startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
        }
    }

    private var buttonGradientColors: [Color] {
        if colorScheme == .dark {
            return [.indigo, .pink]
        } else {
            return [.accentColor, .green]
        }
    }
}

#Preview {
    ButtonDesign(buttonTitle: "Test") { }
}
