//
//  LoginViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import Foundation
import FirebaseAuth

class LogInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""

    func logIn() {
        isLoading = true
        guard validate() else {
            isLoading = false
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, err in
            self?.isLoading = false
            if err != nil {
                self?.errorMessage = err?.localizedDescription ?? ""
            }
        }
    }

    func validate() -> Bool {
        errorMessage = ""

        // Checking if fields are filled
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }

        // Check if email is valid
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter vaild email."
            return false
        }

        return true
    }
}
