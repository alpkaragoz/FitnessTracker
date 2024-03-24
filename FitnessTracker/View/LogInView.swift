//
//  LoginView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 7.12.2023.
//

import SwiftUI

struct LogInView: View {
    @StateObject private var viewModel = LogInViewModel()

    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                VStack {
                    AppLogo()

                    TextField("Email", text: $viewModel.email)
                        .modifier(TextModifier())
                        .foregroundColor(.blue)

                    SecureField("Password", text: $viewModel.password)
                        .modifier(TextModifier())

                    ButtonDesign(buttonTitle: "Login", action: viewModel.logIn)
                        .padding()

                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                }.toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        }
                    }
                }.padding()

                VStack {
                    Text("Don't have an account?")
                    NavigationLink("Register") {
                        SignupView()
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    LogInView()
}
