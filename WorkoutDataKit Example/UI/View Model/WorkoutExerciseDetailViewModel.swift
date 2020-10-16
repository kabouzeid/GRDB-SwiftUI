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

    required init(database: AppDatabase, workoutExercsieID: Int64) {
        self.database = database
        self.workoutExercsieID = workoutExercsieID
    }

    func bind() {
        workoutExerciseDetailCancellable = workoutExerciseDetailPublisher(in: database).assign(to: \.workoutExerciseDetail, on: self)
    }

    func unbind() {
        workoutExerciseDetailCancellable?.cancel()
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
            .catch { error in // or use .replaceError() ???
                // Turn database errors into an empty list.
                // Eventual error presentation is left as an exercise for the reader.
                Just(nil)
            }
            .print()
            .eraseToAnyPublisher()
    }
}
