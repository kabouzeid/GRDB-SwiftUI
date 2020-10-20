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
    @Published private var workoutExerciseDetail: AppDatabase.WorkoutExerciseDetailPublisherResult = (nil, [])

    var workoutSets: [WorkoutSet] {
        workoutExerciseDetail.workoutExerciseWithSets?.workoutSets ?? []
    }
    
    var workoutSetHistory: [AppDatabase.WorkoutSetsWithWorkout] {
        workoutExerciseDetail.workoutExerciseHistory
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

    // MARK: - Workout Set List Management

    func deleteWorkoutSets(atOffsets offsets: IndexSet) {
        // Eventual error presentation is left as an exercise for the reader.
        let workoutSetIDs = offsets.compactMap { workoutSets[$0].id }
        try! database.deleteWorkoutSets(ids: workoutSetIDs)
    }

    // MARK: - Private

    /// Returns a publisher of the workouts in the list
    private func workoutExerciseDetailPublisher(in database: AppDatabase) -> AnyPublisher<AppDatabase.WorkoutExerciseDetailPublisherResult, Never> {
        database.workoutExerciseDetailPublisher(workoutExerciseID: workoutExercsieID)
            .breakpointOnError()
            .replaceError(with: (nil, []))
            .eraseToAnyPublisher()
    }
}
