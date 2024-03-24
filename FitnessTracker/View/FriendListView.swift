//
//  FriendListView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.01.2024.
//

import SwiftUI

struct FriendListView: View {
    @StateObject var viewModel = FriendsListViewModel()
    @State private var friendToDelete: String?

    var body: some View {
        List {
            Section(header: Text("Friend Requests")) {
                ForEach(viewModel.pendingRequestObjects, id: \.id) { request in
                    HStack {
                        Text(request.username)
                        Spacer()
                        Button("Accept") {
                            viewModel.acceptRequest(request.id)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Button("Deny") {
                            viewModel.denyRequest(request.id)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }

            Section(header: Text("Friends")) {
                ForEach(viewModel.friendObjects, id: \.id) { friend in
                    Text(friend.username)
                }
                .onDelete(perform: deleteFriend)
            }

            Section(header: Text("Send Friend Request")) {
                TextField("Enter username", text: $viewModel.usernameToSendRequest)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                Button("Send Request") {
                    viewModel.sendFriendRequest()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        .navigationTitle("Friends")
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .info:
                return Alert(title: Text("Info"),
                             message: Text(viewModel.alertMessage),
                             dismissButton: .default(Text("OK")))
            case .deleteConfirmation:
                return Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this friend?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let friendId = friendToDelete {
                            viewModel.deleteFriend(friendId: friendId)
                        }
                    },
                    secondaryButton: .cancel {
                        friendToDelete = nil
                    }
                )
            }
        }
        .onAppear(perform: viewModel.fetchFriendsAndRequests)
    }

    private func deleteFriend(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        friendToDelete = viewModel.friendIds[index]
        viewModel.activeAlert = .deleteConfirmation
    }
}

#Preview {
    FriendListView()
}
