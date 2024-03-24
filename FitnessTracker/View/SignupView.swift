//
//  SignupView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $viewModel.username)
                        .autocorrectionDisabled()
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    TextField("Email", text: $viewModel.email)
                        .autocorrectionDisabled()
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    SecureField("Password", text: $viewModel.password)
                        .autocorrectionDisabled()
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        ButtonDesign(buttonTitle: "Register") {
                            viewModel.signUp()
                        }
                        .frame(maxWidth: .infinity)
                }
                Section {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
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
            .navigationBarTitle("Sign Up", displayMode: .inline)
        }
    }
}

#Preview {
    SignupView()
}
