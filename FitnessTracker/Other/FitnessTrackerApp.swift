//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FitnessTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var imageData = ImageData(key: "profilePhoto")

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(imageData)
        }
    }
}
