import Foundation
import GRDB

struct Workout: Codable, Identifiable {
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

// SQL generation
extension Workout: TableRecord {
    /// The table columns
    enum Columns {
        static let id = Column(Workout.CodingKeys.id)
        static let title = Column(Workout.CodingKeys.title)
        static let comment = Column(Workout.CodingKeys.comment)
        static let startDate = Column(Workout.CodingKeys.startDate)
        static let endDate = Column(Workout.CodingKeys.endDate)
    }
}

// Fetching methods
extension Workout: FetchableRecord { }

// Persistence methods
extension Workout: MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database Requests
extension DerivableRequest where RowDecoder == Workout {
    func orderedByStartDate() -> Self {
        order(Workout.Columns.startDate.desc, Workout.Columns.title)
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

