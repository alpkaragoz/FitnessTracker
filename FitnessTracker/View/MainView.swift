//
//  MainView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        if viewModel.isSplashing {
            AppLogo()
                .onAppear {
                    viewModel.startSplashSequence()
                }
            Text("Welcome!")
                .padding()
                .bold()
                .italic()
                .opacity(viewModel.splashOpacity)
                .transition(.opacity)
        } else {
            if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                LoggedInView()
            } else {
                LogInView()
            }
        }
    }
}

#Preview {
    MainView()
}
