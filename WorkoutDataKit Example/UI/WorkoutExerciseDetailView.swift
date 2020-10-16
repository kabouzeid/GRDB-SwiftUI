//
//  WorkoutExerciseDetailView.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import SwiftUI

struct WorkoutExerciseDetailView: View {
    @StateObject var viewModel: WorkoutExerciseDetailViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.workoutSets) { workoutSet in
                WorkoutSetCell(viewModel: viewModel.workoutSetCellViewModel(workoutSet: workoutSet))
            }
            .onDelete { offsets in
                self.viewModel.deleteWorkoutExercises(atOffsets: offsets)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text("\(viewModel.workoutSets.count) Workout Sets"))
        .navigationBarItems(trailing: EditButton())
        .onAppear(perform: viewModel.bind)
        .onDisappear(perform: viewModel.unbind)
    }
}

struct WorkoutExerciseDetailView_Previews: PreviewProvider {
    static let appDatabase = AppDatabase.random()
    
    static var workoutExercise: WorkoutExercise? {
        guard let workout = try! appDatabase.workouts().first else { return nil }
        guard let workoutExercise = try! appDatabase.workoutExercises(workoutID: workout.id!).first else { return nil }
        return workoutExercise
    }
    
    static var previews: some View {
        WorkoutExerciseDetailView(viewModel: .init(database: appDatabase, workoutExercsieID: workoutExercise?.id ?? 0))
    }
}
