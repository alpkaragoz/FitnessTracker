//
//  EditWorkoutView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 8.01.2024.
//

import SwiftUI
import FirebaseFirestore

struct EditWorkoutView: View {
    @ObservedObject var viewModel: EditWorkoutViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    Loading(loadingMessage: "Updating")
                } else {
                    Form {
                        HStack {
                            Text("Workout Name:")
                                .foregroundStyle(.blue)
                            Spacer()
                            TextField("Workout Name", text: $viewModel.workoutName)
                        }
                        ForEach($viewModel.sessions.indices, id: \.self) { sessionIndex in
                            Section(header: Text("Session \(sessionIndex + 1)")) {
                                HStack {
                                    Text("Session Name:")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    TextField("Session Name",
                                              text: $viewModel.sessions[sessionIndex].dayOfTheWeek)
                                }
                                ForEach($viewModel.sessions[sessionIndex].moves.indices, id: \.self) { moveIndex in
                                    VStack {
                                        HStack {
                                            Text("Move Name:")
                                                .foregroundStyle(.blue)
                                            Spacer()
                                            TextField("Move Name",
                                                      text: $viewModel.sessions[sessionIndex].moves[moveIndex].name)
                                        }
                                        HStack {
                                            Text("Sets:")
                                                .foregroundStyle(.blue)
                                            Spacer()
                                            TextField("Sets",
                                                      value: $viewModel.sessions[sessionIndex].moves[moveIndex].sets,
                                                      formatter: NumberFormatter())
                                        }
                                        HStack {
                                            Text("Reps:")
                                                .foregroundStyle(.blue)
                                            Spacer()
                                            TextField("Reps",
                                                      value: $viewModel.sessions[sessionIndex].moves[moveIndex].reps,
                                                      formatter: NumberFormatter())
                                        }
                                    }
                                }
                                .onDelete { indices in
                                    viewModel.sessions[sessionIndex].moves.remove(atOffsets: indices)
                                }

                                Button("Add Move") {
                                    let newMove = Move(id: UUID(), name: "", sets: 3, reps: 12)
                                    viewModel.sessions[sessionIndex].moves.append(newMove)
                                }
                            }
                        }
                        .onDelete { indices in
                            viewModel.sessions.remove(atOffsets: indices)
                        }

                        Button("Add Session") {
                            let newSession = Session(id: UUID(), moves: [], dayOfTheWeek: "Session")
                            viewModel.sessions.append(newSession)
                        }

                        Button("Save") {
                            Task {
                                await viewModel.updateWorkout()
                                if viewModel.isOperationSuccessful {
                                    viewModel.onEditComplete()
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }

                        Button("Delete Workout") {
                            viewModel.deleteWorkout()
                            viewModel.onEditComplete()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .alert(isPresented: $viewModel.isErrorPresent) {
                        Alert(title: Text("Error"), message: Text(viewModel.errorMessage),
                              dismissButton: .default(Text("OK")))}
                }
            }
            .navigationBarTitle("Edit Workout")
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        .onAppear {
            viewModel.loadWorkoutData()
        }
    }
}
