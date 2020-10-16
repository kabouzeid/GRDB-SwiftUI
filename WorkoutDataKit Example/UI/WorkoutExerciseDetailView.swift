//
//  WorkoutExerciseDetailView.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import SwiftUI

struct WorkoutExerciseDetailView: View {
    @ObservedObject var viewModel: WorkoutExerciseDetailViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.workoutSets) { workoutSet in
                WorkoutSetRow(workoutSet: workoutSet)
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

struct WorkoutSetRow: View {
    let workoutSet: WorkoutSet
    
    var body: some View {
        Text("\(workoutSet.weight) kg × \(workoutSet.repetitions)")
    }
}

struct WorkoutExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutExerciseDetailView(viewModel: .init(database: .random(), workoutExercsieID: 0))
    }
}
