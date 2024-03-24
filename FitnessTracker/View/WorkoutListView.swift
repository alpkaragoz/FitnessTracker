//
//  ProfileView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.12.2023.
//

import SwiftUI

struct WorkoutListView: View {
    @StateObject var viewModel = WorkoutListViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    Loading(loadingMessage: "Loading")
                } else {
                    List(viewModel.workouts) { workout in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("View: ")
                                Button(workout.name) {
                                    viewModel.selectedWorkout = viewModel.workouts.first(where: { $0.id == workout.id })
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            NavigationLink("Edit",
                                           destination:
                                            EditWorkoutView(viewModel:
                                            EditWorkoutViewModel(workout: workout, onEditComplete: {
                                Task {
                                    await viewModel.fetchWorkouts()
                                } })))
                            .foregroundColor(.blue)
                        }.padding()
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchWorkouts()
                }
            }
            .navigationTitle("My Workouts")
        }
        .sheet(item: $viewModel.selectedWorkout) { workout in
            WorkoutDetailView(workout: workout)
        }
    }
}

#Preview {
    WorkoutListView()
}
