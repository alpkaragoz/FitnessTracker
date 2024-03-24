//
//  EditWorkoutViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 20.01.2024.
//

import Foundation
import FirebaseFirestore

class EditWorkoutViewModel: ObservableObject {
    @Published var workoutName: String = ""
    @Published var sessions: [Session] = []
    @Published var isOperationSuccessful = false
    @Published var isErrorPresent = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    var workout: Workout
    var onEditComplete: () -> Void

    init(workout: Workout, onEditComplete: @escaping () -> Void) {
        self.workout = workout
        self.onEditComplete = onEditComplete
        loadWorkoutData()
    }

    func loadWorkoutData() {
        workoutName = workout.name
        sessions = workout.sessionList
    }

    func updateWorkout() async {
        guard let firebaseId = workout.firebaseId else {return}

        let updatedWorkoutData: [String: Any] = [
            "id": workout.id.uuidString,
            "name": workoutName,
            "userId": workout.userId,
            "sessionList": sessions.map { session in
                [
                    "id": session.id.uuidString,
                    "dayOfTheWeek": session.dayOfTheWeek,
                    "moves": session.moves.map { move in
                        [
                            "id": move.id.uuidString,
                            "name": move.name,
                            "sets": move.sets,
                            "reps": move.reps
                        ]
                    }
                ]
            }
        ]

        if validate(workout: updatedWorkoutData) {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let database = Firestore.firestore()
            do {
                try await database.collection("workouts").document(firebaseId).setData(updatedWorkoutData, merge: true)
                DispatchQueue.main.async {
                    self.isOperationSuccessful = true
                    self.isErrorPresent = false
                    self.errorMessage = ""
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                print("Error updating document: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    private func validate(workout: [String: Any]) -> Bool {
        guard let workoutName = workout["name"] as? String,
              !workoutName.trimmingCharacters(in: .whitespaces).isEmpty else {
            updateError(message: "Please enter a workout name.")
            return false
        }

        guard let sessions = workout["sessionList"] as? [[String: Any]], !sessions.isEmpty else {
            updateError(message: "Please add at least one session.")
            return false
        }

        for session in sessions {
            if let dayOfTheWeek = session["dayOfTheWeek"] as? String,
               dayOfTheWeek.trimmingCharacters(in: .whitespaces).isEmpty {
                updateError(message: "Please do not leave session names empty.")
                return false
            }

            guard let moves = session["moves"] as? [[String: Any]], !moves.isEmpty else {
                updateError(message: "A session cannot be empty.")
                return false
            }

            for move in moves {
                if let moveName = move["name"] as? String, moveName.trimmingCharacters(in: .whitespaces).isEmpty {
                    updateError(message: "Please do not leave move names empty.")
                    return false
                }
            }
        }

        DispatchQueue.main.async {
            self.isErrorPresent = false
            self.errorMessage = ""
        }
        return true
    }

    private func updateError(message: String) {
        DispatchQueue.main.async {
            self.isErrorPresent = true
            self.errorMessage = message
        }
    }

    func deleteWorkout() {
        guard let workoutId = workout.firebaseId else { return }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        let database = Firestore.firestore()
        database.collection("workouts").document(workoutId).delete { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    print("Error deleting workout: \(error)")
                    return
                }
                self.isOperationSuccessful = true
            }
        }
    }

}
