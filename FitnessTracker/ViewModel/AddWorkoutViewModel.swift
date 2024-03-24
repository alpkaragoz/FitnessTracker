//
//  SettignsViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Combine
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

class AddWorkoutViewModel: ObservableObject {
    @Published var workoutName: String = ""
    @Published var sessions: [Session] = []
    @Published var errorMessage = ""
    @Published var isSaveSuccessful: Bool = false

    func saveWorkout() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let workout = Workout(
            id: UUID(),
            name: self.workoutName,
            userId: userId,
            sessionList: sessions.map { session in
                Session(
                    id: UUID(),
                    moves: session.moves.map { move in
                        Move(
                            id: UUID(), name: move.name, sets: move.sets, reps: move.reps
                        )
                    },
                    dayOfTheWeek: session.dayOfTheWeek
                )
            }
        )

        let workoutData: [String: Any] = [
            "id": workout.id.uuidString,
            "name": workout.name,
            "userId": userId,
            "sessionList": workout.sessionList.map { session in
                [
                    "id": session.id.uuidString,
                    "dayOfTheWeek": session.dayOfTheWeek,
                    "moves": session.moves.map { move in
                        [
                            "id": move.id.uuidString, "name": move.name, "sets": move.sets, "reps": move.reps
                        ]
                    }
                ]
            }
        ]

        if validate(workout: workout) {
            DispatchQueue.main.async {
                database.collection("workouts").addDocument(data: workoutData) { error in
                    if error != nil {
                        self.errorMessage = "Failed to save workout."
                    } else {
                        self.isSaveSuccessful = true
                        self.errorMessage = ""
                        DispatchQueue.main.async {
                            self.sessions.removeAll()
                            self.workoutName = ""
                        }
                    }
                }
            }
        }
    }

    func addSession() {
        let newSession = Session(id: UUID(), moves: [], dayOfTheWeek: "")
        DispatchQueue.main.async {
            self.sessions.append(newSession)
        }
    }

    func addMove(to sessionID: UUID) {
        if let index = sessions.firstIndex(where: { $0.id == sessionID }) {
            let newMove = Move(id: UUID(), name: "", sets: 3, reps: 12)
            DispatchQueue.main.async {
                self.sessions[index].moves.append(newMove)
            }
        }
    }

    func removeMove(from sessionID: UUID, at offsets: IndexSet) {
        if let index = sessions.firstIndex(where: { $0.id == sessionID }) {
            DispatchQueue.main.async {
                self.sessions[index].moves.remove(atOffsets: offsets)
            }
        }
    }

    func removeSession(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.sessions.remove(atOffsets: offsets)
        }
    }

    private func validate (workout: Workout) -> Bool {
        for session in workout.sessionList {
            for move in session.moves where move.name.isEmpty {
                DispatchQueue.main.async {
                    self.errorMessage = "Please do not leave move names empty."
                }
                return false
            }
        }

        for session in workout.sessionList where session.dayOfTheWeek.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please do not leave session names empty."
            }
            return false
        }

        for session in workout.sessionList where session.moves.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "A session cannot be empty."
            }
            return false
        }

        if workout.name.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a workout name."
            }
            return false
        }

        if workout.sessionList.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "Please add at least one session."
            }
            return false
        }

        return true
    }
}
