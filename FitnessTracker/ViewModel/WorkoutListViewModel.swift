//
//  WorkoutDetailViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Combine
import FirebaseFirestore
import FirebaseAuth

class WorkoutListViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var selectedWorkout: Workout?
    @Published var editingWorkout: Workout?
    @Published var isLoading = false
    private var database = Firestore.firestore()

    func fetchWorkouts() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }

        do {
            let snapshot = try await database.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            let fetchedWorkouts = snapshot.documents.compactMap { doc in
                try? doc.data(as: Workout.self)
            }
            DispatchQueue.main.async {
                self.workouts = fetchedWorkouts
                self.isLoading = false
            }
        } catch {
            print("Error getting documents: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
