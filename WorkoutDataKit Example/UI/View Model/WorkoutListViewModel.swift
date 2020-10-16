//
//  WorkoutListViewModel.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation
import Combine

class WorkoutListViewModel: ObservableObject {
    /// The workouts in the list
    @Published var workouts = [Workout]()
    
    private let database: AppDatabase
    private var workoutsCancellable: AnyCancellable?
    
    init(database: AppDatabase) {
        print("INIT WORKOUT_LIST_VIEWMODEL")
        self.database = database
    }
    
    func bind() {
        print("BIND WORKOUT_LIST_VIEWMODEL")
        workoutsCancellable = workoutsPublisher(in: database).assign(to: \.workouts, on: self)
    }
    
    func unbind() {
        print("UNBIND WORKOUT_LIST_VIEWMODEL")
        workoutsCancellable?.cancel()
    }
    
    deinit {
        print("DEINIT WORKOUT_LIST_VIEWMODEL")
    }
    
    func workoutDetailViewModel(workout: Workout) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(database: database, workoutID: workout.id!)
    }
    
    // MARK: - Workout List Management
    
    func deleteWorkouts(atOffsets offsets: IndexSet) {
        // Eventual error presentation is left as an exercise for the reader.
        let workoutIDs = offsets.compactMap { workouts[$0].id }
        try! database.deleteWorkouts(ids: workoutIDs)
    }
    
    // MARK: - Private
    
    /// Returns a publisher of the workouts in the list
    private func workoutsPublisher(in database: AppDatabase) -> AnyPublisher<[Workout], Never> {
        database.workoutsOrderedByStartDatePublisher()
            .breakpointOnError()
            .catch { error in
                // Turn database errors into an empty list.
                // Eventual error presentation is left as an exercise for the reader.
                Just<[Workout]>([])
            }
//            .print()
            .eraseToAnyPublisher()
    }
}
