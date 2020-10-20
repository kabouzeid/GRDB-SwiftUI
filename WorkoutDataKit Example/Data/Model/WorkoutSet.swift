//
//  WorkoutSet.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation
import GRDB

struct WorkoutSet: Codable, Identifiable {
    var id: Int64?
    
    var orderIndex: Int64
    
    var weight: Double
    var repetitions: Int64
    
    var workoutExerciseID: Int64
}

extension WorkoutSet {
    static let workoutExercise = belongsTo(WorkoutExercise.self)
}

extension WorkoutSet {
    var workoutExercise: QueryInterfaceRequest<WorkoutExercise> {
        request(for: Self.workoutExercise)
    }
}

// SQL generation
extension WorkoutSet: TableRecord{
    /// The table columns
    enum Columns {
        static let id = Column(WorkoutSet.CodingKeys.id)
        static let orderIndex = Column(WorkoutSet.CodingKeys.orderIndex)
        static let weight = Column(WorkoutSet.CodingKeys.weight)
        static let repetitions = Column(WorkoutSet.CodingKeys.repetitions)
        static let workoutExerciseID = Column(WorkoutSet.CodingKeys.workoutExerciseID)
    }
}

// Fetching methods
extension WorkoutSet: FetchableRecord { }

// Persistence methods
extension WorkoutSet: MutablePersistableRecord {
    /// Updates a workout id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database Requests
extension DerivableRequest where RowDecoder == WorkoutSet {
    func filterBy(workoutExerciseID: Int64) -> Self {
        filter(WorkoutSet.Columns.workoutExerciseID == workoutExerciseID)
    }
    
    func ordered() -> Self {
        order(WorkoutSet.Columns.orderIndex)
    }
}

extension WorkoutSet {    
    /// Creates a new player with random name and random score
    static func newRandom(orderIndex: Int64, workoutExerciseID: Int64) -> WorkoutSet {
        WorkoutSet(orderIndex: orderIndex, weight: randomWeight(), repetitions: randomRepetitions(), workoutExerciseID: workoutExerciseID)
    }
    
    /// Returns a random name
    static func randomWeight() -> Double {
        2.5 * Double(Int.random(in: 8...40))
    }
    
    static func randomRepetitions() -> Int64 {
        Int64.random(in: 1...12)
    }
}
