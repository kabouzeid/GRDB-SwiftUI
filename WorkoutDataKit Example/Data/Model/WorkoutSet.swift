//
//  WorkoutSet.swift
//  WorkoutDataKit Example
//
//  Created by Karim Abou Zeid on 16.10.20.
//

import Foundation
import GRDB

struct WorkoutSet {
    var id: Int64?
    
    var orderIndex: Int64
    
    var weight: Double
    var repetitions: Int64
    
    var workoutExerciseID: Int64
}

extension WorkoutSet {
    static let workoutExercise = hasOne(WorkoutExercise.self)
}

extension WorkoutSet {
    var workoutExercise: QueryInterfaceRequest<WorkoutExercise> {
        request(for: Self.workoutExercise)
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

// MARK: - Persistence

/// Make WorkoutExercise a Codable Record.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension WorkoutSet: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let orderIndex = Column(CodingKeys.orderIndex)
        static let weight = Column(CodingKeys.weight)
        static let repetitions = Column(CodingKeys.repetitions)
        static let workoutExerciseID = Column(CodingKeys.workoutExerciseID)
    }
    
    /// Updates a workout id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Player Database Requests

/// Define some workout requests used by the application.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
/// See https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
extension DerivableRequest where RowDecoder == WorkoutSet {
    func filterBy(workoutExerciseID: Int64) -> Self {
        filter(WorkoutSet.Columns.workoutExerciseID == workoutExerciseID)
    }
    
    func ordered() -> Self {
        order(WorkoutSet.Columns.orderIndex)
    }
}

extension WorkoutSet: Identifiable {}
