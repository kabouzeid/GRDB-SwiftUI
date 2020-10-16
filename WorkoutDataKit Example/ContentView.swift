//
//  ContentView.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 15.10.20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationView {
                WorkoutList(viewModel: WorkoutListViewModel(database: AppDatabase.shared))
            }
            toolbar
        }
    }
    
    private var toolbar: some View {
        HStack {
            Button(
                action: deleteAllWorkouts,
                label: { Image(systemName: "trash").imageScale(.large) }
            )
            Spacer()
            Button(
                action: randomiseWorkouts,
                label: { Image(systemName: "arrow.clockwise").imageScale(.large) }
            )
            Spacer()
            Button(
                action: stressTest,
                label: { Image(systemName: "tornado").imageScale(.large) }
            )
        }
        .padding()
    }
}

extension ContentView {
    /// Deletes all workouts
    func deleteAllWorkouts() {
        // Eventual error presentation is left as an exercise for the reader.
        try! AppDatabase.shared.deleteAllWorkouts()
    }
    
    /// Refreshes the list of players
    func randomiseWorkouts() {
        // Eventual error presentation is left as an exercise for the reader.
        try! AppDatabase.shared.randomiseWorkouts()
    }
    
    /// Spawns many concurrent database updates, for demo purpose
    func stressTest() {
        for _ in 0..<50 {
            DispatchQueue.global().async {
                self.randomiseWorkouts()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//struct SOTest: View {
//    @State private var workout: Workout?
//
//    var body: some View {
//        VStack {
//            Text("Workout ID: \(workout?.id.map { String($0) } ?? "nil")")
//
//            if let id = workout?.id {
//                WorkoutDetailView(viewModel: .init(database: .shared, workoutID: id))
//                    .id(id)
//            }
//
//            Button("Show Random Workout") {
//                self.workout = try! AppDatabase.shared.workouts().randomElement()!
//            }
//        }
//    }
//}
