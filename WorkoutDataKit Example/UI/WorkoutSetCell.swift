//
//  WorkoutSetCell.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import SwiftUI

struct WorkoutSetCell: View {
    let viewModel: WorkoutSetCellViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title)
                .font(Font.headline.monospacedDigit())
            
            HStack {
                Stepper("W", onIncrement: viewModel.incrementWeight, onDecrement: viewModel.decrementWeight)
                Stepper("R", onIncrement: viewModel.incrementRepetitions, onDecrement: viewModel.decrementRepetitions)
            }
        }
    }
}

struct WorkoutSetCell_Previews: PreviewProvider {
    static let appDatabase = AppDatabase.random()
    
    static var workoutSet: WorkoutSet? {
        guard let workout = try! appDatabase.workouts().first else { return nil }
        guard let workoutExercise = try! appDatabase.workoutExercises(workoutID: workout.id!).first else { return nil }
        guard let workoutSet = try! appDatabase.workoutSets(workoutExerciseID: workoutExercise.id!).first else { return nil }
        return workoutSet
    }
    
    static var previews: some View {
        WorkoutSetCell(viewModel: .init(database: appDatabase, workoutSet: workoutSet!))
    }
}
