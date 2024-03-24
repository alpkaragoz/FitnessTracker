//
//  User.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var firebaseId: String?
    var id: String? { firebaseId }
    var username: String
    var email: String
    let joined: TimeInterval
    var friends: [String]
    var pendingFriendRequests: [String]
}
