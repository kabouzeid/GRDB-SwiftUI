import Foundation
import GRDB

struct WorkoutExercise {
    var id: Int64?
    
    var orderIndex: Int64
    
    var name: String
    var workoutID: Int64
}

extension WorkoutExercise {
    static let workout = hasOne(Workout.self)
    static let workoutSets = hasMany(WorkoutSet.self)
}

extension WorkoutExercise {
    var workout: QueryInterfaceRequest<Workout> {
        request(for: Self.workout)
    }
    
    var workoutSets: QueryInterfaceRequest<WorkoutSet> {
        request(for: Self.workoutSets)
    }
}

extension WorkoutExercise {
    private static let names = ["Bench Press", "Deadlift", "Squats", "Overhead Press", "Triceps Extensions", "Biceps Curls"]
    
    /// Creates a new player with random name and random score
    static func newRandom(orderIndex: Int64, workoutID: Int64) -> WorkoutExercise {
        WorkoutExercise(orderIndex: orderIndex, name: randomName(), workoutID: workoutID)
    }
    
    /// Returns a random name
    static func randomName() -> String {
        names.randomElement()!
    }
}

// MARK: - Persistence

/// Make WorkoutExercise a Codable Record.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension WorkoutExercise: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let orderIndex = Column(CodingKeys.orderIndex)
        static let name = Column(CodingKeys.name)
        static let workoutID = Column(CodingKeys.workoutID)
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
extension DerivableRequest where RowDecoder == WorkoutExercise {
    /// A request of workouts ordered by start date
    ///
    /// For example:
    ///
    ///     let workouts = try dbQueue.read { db in
    ///         try Workout.all().orderedByStartDate().fetchAll(db)
    ///     }
    func filterByWorkout(key: Int64) -> Self {
        filter(WorkoutExercise.Columns.workoutID == key)
    }
    
    func ordered() -> Self {
        order(WorkoutExercise.Columns.orderIndex)
    }
}

extension WorkoutExercise: Identifiable {}
