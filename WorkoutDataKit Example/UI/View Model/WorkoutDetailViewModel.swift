//
//  WorkoutDetailViewModel.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation
import Combine
import SwiftUI

class WorkoutDetailViewModel: ObservableObject {
    @Published private var workoutDetail: AppDatabase.WorkoutDetail?
    
    var workoutExercises: [WorkoutExercise] {
        workoutDetail?.workoutExercises ?? []
    }
    
    var workoutTitle: Binding<String> {
        Binding {
            self.workoutDetail?.workout.title ?? ""
        } set: { newValue in
            self.workoutDetail?.workout.title = newValue
        }
    }
    
    private let database: AppDatabase
    private let workoutID: Int64
    private var workoutDetailCancellable: AnyCancellable?
    
    required init(database: AppDatabase, workoutID: Int64) {
        self.database = database
        self.workoutID = workoutID
    }
    
    func bind() {
        workoutDetailCancellable = workoutDetailPublisher(in: database).assign(to: \.workoutDetail, on: self)
    }
    
    func unbind() {
        workoutDetailCancellable?.cancel()
    }
    
    // MARK: - Workout Exercise List Management
    
    func deleteWorkoutExercises(atOffsets offsets: IndexSet) {
        // Eventual error presentation is left as an exercise for the reader.
        let workoutExerciseIDs = offsets.compactMap { workoutDetail?.workoutExercises[$0].id }
        try! database.deleteWorkoutExercises(ids: workoutExerciseIDs)
    }
    
    // MARK: - Workout
    
    func finishEditingTitle() {
        adjustTitle()
        updateWorkout()
    }
    
    func workoutExerciseDetailViewModel(workoutExercise: WorkoutExercise) -> WorkoutExerciseDetailViewModel {
        WorkoutExerciseDetailViewModel(database: database, workoutExercsieID: workoutExercise.id!)
    }
    
    // MARK: - Private
    
    /// Returns a publisher of the workouts in the list
    private func workoutDetailPublisher(in database: AppDatabase) -> AnyPublisher<AppDatabase.WorkoutDetail?, Never> {
        database.workoutDetailPublisher(workoutID: workoutID)
            .catch { error in // or use .replaceError() ???
                // Turn database errors into an empty list.
                // Eventual error presentation is left as an exercise for the reader.
                Just(nil)
            }
            .print()
            .eraseToAnyPublisher()
    }
    
    private func adjustTitle() {
        workoutTitle.wrappedValue = workoutTitle.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func updateWorkout() {
        guard var workout = workoutDetail?.workout else { return }
        try! database.updateWorkout(&workout)
        workoutDetail?.workout = workout
    }
}
