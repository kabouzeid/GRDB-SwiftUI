import Foundation
import GRDB

struct WorkoutExercise: Codable, Identifiable {
    var id: Int64?
    
    var orderIndex: Int64
    
    var name: String
    var workoutID: Int64
}

extension WorkoutExercise {
    static let workout = belongsTo(Workout.self)
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

// SQL generation
extension WorkoutExercise: TableRecord {
    /// The table columns
    enum Columns {
        static let id = Column(WorkoutExercise.CodingKeys.id)
        static let orderIndex = Column(WorkoutExercise.CodingKeys.orderIndex)
        static let name = Column(WorkoutExercise.CodingKeys.name)
        static let workoutID = Column(WorkoutExercise.CodingKeys.workoutID)
    }
}

// Fetching methods
extension WorkoutExercise: FetchableRecord { }

// Persistence methods
extension WorkoutExercise: MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Database Requests
extension DerivableRequest where RowDecoder == WorkoutExercise {
    func filterBy(workoutID: Int64) -> Self {
        filter(WorkoutExercise.Columns.workoutID == workoutID)
    }
    
    func filterBy(name: String) -> Self {
        filter(WorkoutExercise.Columns.name == name)
    }
    
    func ordered() -> Self {
        order(WorkoutExercise.Columns.orderIndex)
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
