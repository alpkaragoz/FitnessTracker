//
//  AppLogo.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 9.12.2023.
//

import SwiftUI

struct AppLogo: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image(colorScheme == .dark ? "appLogoDark" : "appLogoLight")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .padding()
    }
}

#Preview {
    AppLogo()
}
