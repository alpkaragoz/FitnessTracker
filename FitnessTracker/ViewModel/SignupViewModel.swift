//
//  SignupViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignupViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage = ""

    func signUp() {
        guard validate() else {
            return
        }

        isUsernameTaken { [weak self] isTaken in
            if isTaken {
                self?.errorMessage = "Username is already taken."
            } else {
                self?.createUserAccount()
            }
        }
    }

    private func createUserAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            guard let userId = result?.user.uid else {
                return
            }
            self?.insertUserRecord(id: userId)
        }
    }

    private func insertUserRecord(id: String) {
        let newUser: [String: Any] = [
            "username": username,
            "email": email,
            "joined": Date().timeIntervalSince1970,
            "friends": [],
            "pendingFriendRequests": []]

        let database = Firestore.firestore()

        database.collection("users").document(id).setData(newUser)
    }

    private func isUsernameTaken(completion: @escaping (Bool) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                let isTaken = snapshot?.documents.isEmpty == false
                completion(isTaken)
            }
        }
    }

    func validate() -> Bool {
        errorMessage = ""
        // Checking if fields are filled
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }

        // Check if email is valid
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter vaild email."
            return false
        }

        // Check password length
        guard password.count >= 6 else {
            errorMessage = "Your password should be at least 6 characters."
            return false
        }
        return true
    }
}
