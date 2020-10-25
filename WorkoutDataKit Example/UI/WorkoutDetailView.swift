//
//  WorkoutDetailView.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import SwiftUI

struct WorkoutDetailView: View {
    @StateObject var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        List {
            Section {
                TextField("Title", text: viewModel.workoutTitle, onEditingChanged: { isEditingTextField in
                    if !isEditingTextField {
                        viewModel.finishEditingTitle()
                    }
                })
            }
            
            ForEach(viewModel.workoutExercises) { workoutExercise in
                NavigationLink(destination: self.workoutExerciseDetailView(for: workoutExercise)) {
                    WorkoutExerciseRow(workoutExercise: workoutExercise)
                }
            }
            .onDelete { offsets in
                self.viewModel.deleteWorkoutExercises(atOffsets: offsets)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text("\(viewModel.workoutExercises.count) Workout Exercises"))
        .navigationBarItems(trailing: EditButton())
        .onAppear(perform: viewModel.bind)
        .onDisappear(perform: viewModel.unbind)
    }
    
    func workoutExerciseDetailView(for workoutExercise: WorkoutExercise) -> some View {
        WorkoutExerciseDetailView(viewModel: viewModel.workoutExerciseDetailViewModel(workoutExercise: workoutExercise))
    }
}

struct WorkoutExerciseRow: View {
    let workoutExercise: WorkoutExercise
    
    var body: some View {
        Text(workoutExercise.name)
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static let appDatabase = AppDatabase.random()
    
    static var workout: Workout? {
        try! appDatabase.workouts().first
    }
    
    static var previews: some View {
        WorkoutDetailView(viewModel: WorkoutDetailViewModel(database: appDatabase, workoutID: workout?.id ?? 0))
    }
}
