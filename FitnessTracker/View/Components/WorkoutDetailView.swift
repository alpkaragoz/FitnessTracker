//
//  WorkoutDetailView.swift
//  FitnessTracker
//
//  Created by Alp Karagöz on 11.12.2023.
//

import SwiftUI

struct WorkoutDetailView: View {
    var workout: Workout
    @State private var showingEditView = false

    var body: some View {
        List {
            ForEach(workout.sessionList) { session in
                Section(header: Text(session.dayOfTheWeek)) {
                    ForEach(session.moves) { move in
                        VStack(alignment: .leading) {
                            Text(move.name)
                            Text("Sets: \(move.sets)")
                            Text("Reps: \(move.reps)")
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name)
    }
}
