//
//  FriendListViewModel.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.01.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ActiveAlert: Identifiable {
    var id: Int {
        hashValue
    }
    case info, deleteConfirmation
}

class FriendsListViewModel: ObservableObject {
    @Published var activeAlert: ActiveAlert?
    @Published var friendObjects: [Friend] = []
    @Published var friendIds: [String] = []
    @Published var pendingRequestObjects: [Friend] = []
    @Published var pendingRequestIds: [String] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var usernameToSendRequest: String = ""

    private var database = Firestore.firestore()

    func fetchFriendsAndRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.main.async {
            self.friendObjects = []
            self.pendingRequestObjects = []
        }

        database.collection("users").document(userId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self?.friendIds = data?["friends"] as? [String] ?? []
                self?.pendingRequestIds = data?["pendingFriendRequests"] as? [String] ?? []

                for friendId in self?.friendIds ?? [] {
                    self?.database.collection("users").document(friendId).getDocument { (doc, _) in
                        if let doc = doc, doc.exists, let username = doc.data()?["username"] as? String {
                            let friend = Friend(id: friendId, username: username)
                            DispatchQueue.main.async {
                                self?.friendObjects.append(friend)
                            }
                        }
                    }
                }

                for friendId in self?.pendingRequestIds ?? [] {
                    self?.database.collection("users").document(friendId).getDocument { (doc, _) in
                        if let doc = doc, doc.exists, let username = doc.data()?["username"] as? String {
                            let friend = Friend(id: friendId, username: username)
                            DispatchQueue.main.async {
                                self?.pendingRequestObjects.append(friend)
                            }
                        }
                    }
                }

            } else {
                self?.alertMessage = "Error fetching data: \(error?.localizedDescription ?? "Unknown error")"
                self?.activeAlert = .info
                self?.showAlert = true
            }
        }
    }

    func acceptRequest(_ request: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // Transaction to ensure both updates succeed or fail together
        let batch = database.batch()

        let userRef = database.collection("users").document(userId)
        batch.updateData(["friends": FieldValue.arrayUnion([request])], forDocument: userRef)

        let friendRef = database.collection("users").document(request)
        batch.updateData(["friends": FieldValue.arrayUnion([userId])], forDocument: friendRef)
        batch.updateData(["pendingFriendRequests": FieldValue.arrayRemove([request])], forDocument: userRef)

        batch.commit { [weak self] error in
            if let error = error {
                self?.alertMessage = "Error: \(error.localizedDescription)"
                self?.activeAlert = .info
                self?.showAlert = true
            } else {
                self?.alertMessage = "Friend request accepted."
                self?.activeAlert = .info
                self?.showAlert = true
                self?.fetchFriendsAndRequests() // Refresh the lists
            }
        }
    }

    func denyRequest(_ request: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        database.collection("users").document(userId).updateData([
            "pendingFriendRequests": FieldValue.arrayRemove([request])
        ]) { [weak self] error in
            if let error = error {
                self?.alertMessage = "Error: \(error.localizedDescription)"
                self?.activeAlert = .info
                self?.showAlert = true
            } else {
                self?.alertMessage = "Friend request denied."
                self?.activeAlert = .info
                self?.showAlert = true
                self?.fetchFriendsAndRequests() // Refresh the lists
            }
        }
    }

    func sendFriendRequest() {
        guard !usernameToSendRequest.isEmpty, let currentUserId = Auth.auth().currentUser?.uid else {
            alertMessage = "Invalid username or not logged in"
            self.activeAlert = .info
            showAlert = true
            return
        }

        // Check if the user exists and get their ID
        database.collection("users")
            .whereField("username", isEqualTo: usernameToSendRequest).getDocuments { [weak self] (querySnapshot, err) in

                if let err = err {
                    self?.alertMessage = "Error fetching user: \(err.localizedDescription)"
                    self?.activeAlert = .info
                    self?.showAlert = true
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    guard let userId = documents.first?.documentID else { return }
                    self?.addPendingRequest(to: userId, from: currentUserId)
                    self?.fetchFriendsAndRequests()
                } else {
                    self?.alertMessage = "User not found"
                    self?.activeAlert = .info
                    self?.showAlert = true
                }
            }
    }

    private func addPendingRequest(to userId: String, from currentUserId: String) {
        // Add the current user's ID to the target user's pending requests
        let userRef = database.collection("users").document(userId)
        userRef.updateData([
            "pendingFriendRequests": FieldValue.arrayUnion([currentUserId])
        ]) { [weak self] error in
            if let error = error {
                self?.activeAlert = .info
                self?.alertMessage = "Error sending request: \(error.localizedDescription)"
                self?.showAlert = true
            } else {
                self?.activeAlert = .info
                self?.alertMessage = "Friend request sent successfully."
                self?.showAlert = true
                self?.usernameToSendRequest = ""
            }
        }
    }

    func deleteFriend(friendId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.activeAlert = .info
            alertMessage = "Error: Not logged in"
            showAlert = true
            return
        }

        let batch = database.batch()

        // Remove friend from current user's list
        let currentUserRef = database.collection("users").document(currentUserId)
        batch.updateData(["friends": FieldValue.arrayRemove([friendId])], forDocument: currentUserRef)

        // Remove current user from friend's list
        let friendRef = database.collection("users").document(friendId)
        batch.updateData(["friends": FieldValue.arrayRemove([currentUserId])], forDocument: friendRef)

        batch.commit { [weak self] error in
            if let error = error {
                self?.activeAlert = .info
                self?.alertMessage = "Error deleting friend: \(error.localizedDescription)"
                self?.showAlert = true
            } else {
                self?.activeAlert = .info
                self?.alertMessage = "Friend deleted successfully."
                self?.showAlert = true
                self?.fetchFriendsAndRequests() // Refresh the lists
            }
        }
    }
}
