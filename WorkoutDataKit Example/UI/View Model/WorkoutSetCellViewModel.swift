//
//  WorkoutSetCellViewModel.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation

class WorkoutSetCellViewModel {
    var title: String {
        "\(String(format: "%.1f", workoutSet.weight)) kg × \(workoutSet.repetitions)"
    }
    
    private var workoutSet: WorkoutSet
    private let database: AppDatabase

    init(database: AppDatabase, workoutSet: WorkoutSet) {
        print("INIT WORKOUT_SET_CELL_VIEWMODEL")
        self.database = database
        self.workoutSet = workoutSet
    }
    
    deinit {
        print("DEINIT WORKOUT_SET_CELL_VIEWMODEL")
    }
    
    func incrementWeight() {
        workoutSet.weight += 2.5
        try! database.updateWorkoutSet(&workoutSet)
    }
    
    func decrementWeight() {
        workoutSet.weight = max(workoutSet.weight - 2.5, 0)
        try! database.updateWorkoutSet(&workoutSet)
    }
    
    func incrementRepetitions() {
        workoutSet.repetitions += 1
        try! database.updateWorkoutSet(&workoutSet)
    }
    
    func decrementRepetitions() {
        workoutSet.repetitions = max(workoutSet.repetitions - 1, 0)
        try! database.updateWorkoutSet(&workoutSet)
    }
}
