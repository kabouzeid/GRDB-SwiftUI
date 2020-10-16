//
//  WorkoutExerciseDetailViewModel.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation
import Combine
import SwiftUI

class WorkoutExerciseDetailViewModel: ObservableObject {
    @Published private var workoutExerciseDetail: AppDatabase.WorkoutExerciseDetail?

    var workoutSets: [WorkoutSet] {
        workoutExerciseDetail?.workoutSets ?? []
    }

    private let database: AppDatabase
    private let workoutExercsieID: Int64
    private var workoutExerciseDetailCancellable: AnyCancellable?

    init(database: AppDatabase, workoutExercsieID: Int64) {
        print("INIT WORKOUT_EXERCISE_DETAIL_VIEWMODEL")
        self.database = database
        self.workoutExercsieID = workoutExercsieID
    }

    func bind() {
        print("BIND WORKOUT_EXERCISE_DETAIL_VIEWMODEL")
        workoutExerciseDetailCancellable = workoutExerciseDetailPublisher(in: database).assign(to: \.workoutExerciseDetail, on: self)
    }

    func unbind() {
        print("UNBIND WORKOUT_EXERCISE_DETAIL_VIEWMODEL")
        workoutExerciseDetailCancellable?.cancel()
    }
    
    deinit {
        print("DEINIT WORKOUT_EXERCISE_DETAIL_VIEWMODEL")
    }
    
    func workoutSetCellViewModel(workoutSet: WorkoutSet) -> WorkoutSetCellViewModel {
        WorkoutSetCellViewModel(database: database, workoutSet: workoutSet)
    }

    // MARK: - Workout Exercise List Management

    func deleteWorkoutExercises(atOffsets offsets: IndexSet) {
        // Eventual error presentation is left as an exercise for the reader.
        let workoutExerciseIDs = offsets.compactMap { workoutExerciseDetail?.workoutSets[$0].id }
        try! database.deleteWorkoutExercises(ids: workoutExerciseIDs)
    }

    // MARK: - Private

    /// Returns a publisher of the workouts in the list
    private func workoutExerciseDetailPublisher(in database: AppDatabase) -> AnyPublisher<AppDatabase.WorkoutExerciseDetail?, Never> {
        database.workoutExerciseDetailPublisher(workoutExerciseID: workoutExercsieID)
            .breakpointOnError()
            .catch { error in // or use .replaceError() ???
                // Turn database errors into an empty list.
                // Eventual error presentation is left as an exercise for the reader.
                Just(nil)
            }
//            .print()
            .eraseToAnyPublisher()
    }
}
