//
//  LoggedInView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.12.2023.
//

import SwiftUI

enum Tab {
    case profile
    case workouts
    case addWorkout
}

struct LoggedInView: View {
    @State private var selectedTab: Tab = .workouts

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ProfileView()
                    .tabItem {
                        Label("My Profile", systemImage: "person")
                    }
                    .tag(Tab.profile)

                WorkoutListView()
                    .tabItem {
                        Label("My Workouts", systemImage: "list.bullet")
                    }
                    .tag(Tab.workouts)

                AddWorkoutView()
                    .tabItem {
                        Label("Add Workout", systemImage: "plus")
                    }
                    .tag(Tab.addWorkout)
            }
        }
    }
}

#Preview {
    LoggedInView()
}
