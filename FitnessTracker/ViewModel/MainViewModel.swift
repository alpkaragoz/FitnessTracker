//
//  MainViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.12.2023.
//

import Foundation
import SwiftUI
import FirebaseAuth

class MainViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var isSplashing: Bool = true
    @Published var splashOpacity: Double = 1.0

    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUserId = user?.uid ?? ""
        }
    }

    func startSplashSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeOut(duration: 2.0)) {
                self.splashOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isSplashing = false
            }
        }
    }

    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
