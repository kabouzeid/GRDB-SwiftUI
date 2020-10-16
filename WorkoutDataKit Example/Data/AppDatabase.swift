import GRDB
import Combine

/// AppDatabase lets the application access the database.
///
/// It applies the pratices recommended at
/// https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
struct AppDatabase {
    private let dbWriter: DatabaseWriter
    
    /// Creates an AppDatabase and make sure the database schema is ready.
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("createWorkout") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "workout") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                    // Sort player names in a localized case insensitive fashion by default
                    // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
                    .collate(.localizedCaseInsensitiveCompare)
                t.column("comment", .text)
                t.column("startDate", .date).notNull()
                t.column("endDate", .date)
            }
            
            try db.create(table: "workoutExercise") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("orderIndex", .integer).notNull()
                t.column("name", .text).notNull()
                    // Sort player names in a localized case insensitive fashion by default
                    // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
                    .collate(.localizedCaseInsensitiveCompare)
                t.column("workoutID", .integer).notNull().references("workout", onDelete: .cascade)
            }
            
            try db.create(table: "workoutSet") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("orderIndex", .integer).notNull()
                t.column("weight", .double).notNull()
                t.column("repetitions", .integer).notNull()
                t.column("workoutExerciseID", .integer).notNull().references("workoutExercise", onDelete: .cascade)
            }
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }
}

// MARK: - Database Access
//
// This extension defines methods that fulfill application needs, both in terms
// of writes and reads.
extension AppDatabase {
    // MARK: Writes
    
    /// Save (insert or update) a workout.
    func saveWorkout(_ workout: inout Workout) throws {
        try dbWriter.write { db in
            try workout.save(db)
        }
    }
    
    /// Delete the specified workouts
    func deleteWorkouts(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try Workout.deleteAll(db, keys: ids)
        }
    }
    
    /// Delete all workouts
    func deleteAllWorkouts() throws {
        try dbWriter.write { db in
            _ = try Workout.deleteAll(db)
        }
    }
    
    /// Refresh all workouts (by performing some random changes, for demo purpose).
    func randomiseWorkouts() throws {
        try dbWriter.write { db in
            if try Workout.fetchCount(db) == 0 {
                // Insert new random players
                try _createRandomWorkouts(db)
            } else {
                // Insert a workout
                if Bool.random() {
                    try _createRandomWorkout(db)
                }
                // Delete a random workout
                if Bool.random() {
                    try Workout.order(sql: "RANDOM()").limit(1).deleteAll(db)
                }
                // Update some players
                for var workout in try Workout.fetchAll(db) where Bool.random() {
                    try workout.updateChanges(db) {
                        $0.title = Workout.randomTitle()
                    }
                }
            }
        }
    }
    
    /// Create random players if the database is empty.
    func createRandomWorkoutsIfEmpty() throws {
        try dbWriter.write { db in
            if try Workout.fetchCount(db) == 0 {
                try _createRandomWorkouts(db)
            }
        }
    }
    
    /// Support for `createRandomWorkoutsIfEmpty()` and `randomiseWorkouts()`.
    private func _createRandomWorkouts(_ db: Database) throws {
        for _ in 0 ..< 8 {
            try _createRandomWorkout(db)
        }
    }
    
    private func _createRandomWorkout(_ db: Database) throws {
        var workout = Workout.newRandom()
        try workout.insert(db)
        
        for workoutExerciseIdx in 0 ..< 5 {
            var workoutExercise = WorkoutExercise.newRandom(orderIndex: Int64(workoutExerciseIdx), workoutID: workout.id!)
            try workoutExercise.insert(db)
            
            for workoutSetIdx in 0 ..< 3 {
                var workoutSet = WorkoutSet.newRandom(orderIndex: Int64(workoutSetIdx), workoutExerciseID: workoutExercise.id!)
                try workoutSet.insert(db)
            }
        }
    }
    
    // MARK: Reads
    
    /// Returns a publisher that tracks changes in players ordered by name
    func workoutsOrderedByStartDatePublisher() -> AnyPublisher<[Workout], Error> {
        ValueObservation
            .tracking(Workout.all().orderedByStartDate().fetchAll)
            .publisher(in: dbWriter)
            .eraseToAnyPublisher()
    }
}

extension AppDatabase {
    // MARK: Writes
    
    /// Delete the specified workouts
    func deleteWorkoutExercises(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try WorkoutExercise.deleteAll(db, keys: ids)
        }
    }
    
    // MARK: Reads
    
    struct WorkoutDetail: Decodable, FetchableRecord {
        var workout: Workout
        var workoutExercises: [WorkoutExercise]
    }
    func workoutDetailPublisher(workoutID: Int64) -> AnyPublisher<WorkoutDetail?, Error> {
        ValueObservation
            .tracking { db in
                let request = Workout
                    .filter(key: workoutID)
                    .including(all: Workout.workoutExercises.ordered())
                return try WorkoutDetail.fetchOne(db, request)
            }
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    /// Save (insert or update) a workout.
    func updateWorkout(_ workout: inout Workout) throws {
        try dbWriter.write { db in
            try workout.update(db)
        }
    }
}

extension AppDatabase {
    // MARK: Writes
    
    /// Delete the specified workouts
    func deleteWorkoutSets(ids: [Int64]) throws {
        try dbWriter.write { db in
            _ = try WorkoutSet.deleteAll(db, keys: ids)
        }
    }
    
    // MARK: Reads
    
    struct WorkoutExerciseDetail: Decodable, FetchableRecord {
        var workoutExercise: WorkoutExercise
        var workoutSets: [WorkoutSet]
    }
    func workoutExerciseDetailPublisher(workoutExerciseID: Int64) -> AnyPublisher<WorkoutExerciseDetail?, Error> {
        ValueObservation
            .tracking { db in
                let request = WorkoutExercise
                    .filter(key: workoutExerciseID)
                    .including(all: WorkoutExercise.workoutSets)
                return try WorkoutExerciseDetail.fetchOne(db, request)
            }
            .publisher(in: dbWriter, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}
