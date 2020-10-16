import Foundation
import GRDB

struct Workout {
    var id: Int64?
    
    var title: String
    var comment: String?
    
    var startDate: Date
    var endDate: Date?
}

extension Workout {
    static let workoutExercises = hasMany(WorkoutExercise.self)
}

extension Workout {
    var workoutExercises: QueryInterfaceRequest<WorkoutExercise> {
        request(for: Self.workoutExercises)
    }
}

extension Workout {
    private static let titles = ["Chest", "Biceps", "Triceps", "Back", "Legs"]
    
    /// Creates a new player with empty name and zero score
    static func new() -> Workout {
        Workout(title: "", startDate: Date())
    }
    
    /// Creates a new player with random name and random score
    static func newRandom() -> Workout {
        Workout(title: randomTitle(), startDate: Date().advanced(by: 60 * 60 * 24 * Double.random(in: -30...30)))
    }
    
    /// Returns a random name
    static func randomTitle() -> String {
        titles.randomElement()!
    }
}

// MARK: - Persistence

/// Make Player a Codable Record.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Workout: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let comment = Column(CodingKeys.comment)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.endDate)
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
extension DerivableRequest where RowDecoder == Workout {
    /// A request of workouts ordered by start date
    ///
    /// For example:
    ///
    ///     let workouts = try dbQueue.read { db in
    ///         try Workout.all().orderedByStartDate().fetchAll(db)
    ///     }
    func orderedByStartDate() -> Self {
        order(Workout.Columns.startDate.desc, Workout.Columns.title)
    }
}

extension Workout: Identifiable {}
