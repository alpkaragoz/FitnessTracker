//
//  ProfileView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 10.12.2023.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var imageData: ImageData
    @ObservedObject private var viewModel = ProfileViewModel()
    @State private var isImagePickerPresented = false
    @State private var profileImage: Image?
    @State private var age: Int = 25
    @State private var gender: String = "Male"
    @State private var height: Double = 170.0
    @State private var weight: Double = 70.0
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        HStack {
                            Text("Age:")
                            Stepper(value: $age, in: 1...120) {
                                Text("\(age)")
                            }
                        }

                        HStack {
                            Text("Gender:")
                            Picker("Gender", selection: $gender) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                            }
                        }

                        HStack {
                            Text("Height:")
                            Slider(value: $height, in: 100...250, step: 1.0)
                            Text("\(Int(height)) cm")
                        }

                        HStack {
                            Text("Weight:")
                            Slider(value: $weight, in: 30...300, step: 1.0)
                            Text("\(Int(weight)) kg")
                        }
                    }

                    Button("Save Changes") {
                        viewModel.saveUserProfile(
                            data: .init(
                                age: age,
                                gender: gender,
                                height: height,
                                weight: weight
                            )
                        ) { error in
                            if let error = error {
                                alertMessage = "Error saving profile data: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Profile data saved successfully"
                            }

                            isShowingAlert = true
                        }
                    }.alert(isPresented: $isShowingAlert) {
                        Alert(
                            title: Text("Save Profile"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    Button("Sign Out") {
                        viewModel.logout()
                    }
                    .foregroundColor(.red)

                    Section {
                        NavigationLink(destination: FriendListView()) {
                            Text("My Friends")
                        }
                    }
                }
            }
            .onAppear(perform: {
                viewModel.getUserProfile { profile, _ in
                    if let profile = profile {
                        age = profile.age
                        gender = profile.gender
                        height = profile.height
                        weight = profile.weight
                    }
                }
            })
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
