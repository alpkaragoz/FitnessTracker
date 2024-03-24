//
//  ProfileViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 11.12.2023.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    private var database = Firestore.firestore()
    @Published var isLoading = true

    func getUserProfile(completion: @escaping (Profile?, Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        let userDocumentRef = database.collection("users").document(currentUserID)
        userDocumentRef.getDocument { (document, error) in
            guard error == nil else { return }
            if let document = document, document.exists {
                if let data = document.data(),
                   let age = data["age"] as? Int,
                   let gender = data["gender"] as? String,
                   let height = data["height"] as? Double,
                   let weight = data["weight"] as? Double {
                    completion(Profile(age: age, gender: gender, height: height, weight: weight), nil)
                }
            }
        }
    }

    func saveUserProfile(data: Profile, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let userData: [String: Any] = [
            "age": data.age,
            "gender": data.gender,
            "height": data.height,
            "weight": data.weight
        ]
        database.collection("users").document(currentUserID).setData(userData, merge: true) { error in
            completion(error)
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logout error")
        }
    }
}
