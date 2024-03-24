//
//  SettingsView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 9.12.2023.
//

import SwiftUI

struct AddWorkoutView: View {
    @StateObject private var viewModel = AddWorkoutViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $viewModel.workoutName)
                }

                ForEach($viewModel.sessions) { $session in
                    Section(header: Text("Session")) {
                        TextField("Session Name", text: $session.dayOfTheWeek)

                        ForEach($session.moves) { $move in
                            VStack {
                                HStack {
                                    Text("Move Name:")
                                        .foregroundStyle(.blue)

                                    Spacer()

                                    TextField("Move Name", text: $move.name)
                                }
                                HStack {
                                    Text("Sets:")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    TextField("Sets", value: $move.sets, formatter: NumberFormatter())
                                }
                                HStack {
                                    Text("Reps:")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    TextField("Reps", value: $move.reps, formatter: NumberFormatter())
                                }
                            }
                        }
                        .onDelete { indices in
                            viewModel.removeMove(from: session.id, at: indices)
                        }

                        Button("Add Move") {
                            viewModel.addMove(to: session.id)
                        }
                    }
                }
                .onDelete { indices in
                    viewModel.removeSession(at: indices)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }

                Button("Add Session") {
                    viewModel.addSession()
                }

                Button(action: viewModel.saveWorkout) {
                    Text("Save Workout")
                }
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        UIApplication.shared
                            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .navigationTitle(Text("Create Workout"))
            .alert(isPresented: $viewModel.isSaveSuccessful) {
                Alert(title: Text("Success"),
                      message: Text("Workout saved successfully!"),
                      dismissButton: .default(Text("OK")))}
        }
    }
}

struct WorkoutCreationView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView()
    }
}
