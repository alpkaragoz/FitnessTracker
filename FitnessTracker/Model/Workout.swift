//
//  Workout.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Foundation
import FirebaseFirestore

struct Workout: Codable, Identifiable {
    @DocumentID var firebaseId: String?
    var id: UUID
    var name: String
    var userId: String
    var sessionList: [Session]
}

struct Session: Identifiable, Codable {
    var id = UUID()
    var moves: [Move] = []
    var dayOfTheWeek: String = ""
}

struct Move: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var sets: Int = 0
    var reps: Int = 0
}
