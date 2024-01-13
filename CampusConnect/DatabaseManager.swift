//
//  DatabaseManager.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.

import Foundation
import GRDB

class DatabaseManager {
    private let dbWriter: any DatabaseWriter
    
    var dbReader: DatabaseReader {
        dbWriter
    }

    static let shared = makeShared()

    private static func makeShared() -> DatabaseManager {
        do {
            let databaseURL = try FileManager.default
                .url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Assignment10_test1.sqlite")

            let dbPool = try DatabasePool(path: databaseURL.path)
            let databaseManager = try DatabaseManager(dbWriter: dbPool)
            return databaseManager
        } catch {
            fatalError("Database initialization failed: \(error)")
        }
    }

    init(dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.eraseDatabaseOnSchemaChange = true

        // Define migrations for specific tables
        migrator.registerMigration("createTables") { db in
            try db.create(table: "college", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("address", .text).notNull()
                t.column("imageData", .blob)
            }

            try db.create(table: "courseCategory", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
            }

            try db.create(table: "program", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("collegeId", .integer).notNull().indexed().references("college", onDelete: .cascade)
            }

            try db.create(table: "course", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("collegeId", .integer).notNull().indexed().references("college", onDelete: .cascade)
                t.column("programId", .integer).notNull().indexed().references("program", onDelete: .cascade)
                t.column("courseCategoryId", .integer).notNull().indexed().references("courseCategory", onDelete: .cascade)
            }
        }

        return migrator
    }

    // Database operations
    func saveRecord<T: MutablePersistableRecord>(item: T) {
        do {
            try dbWriter.write { db in
                var mutableItem = item
                try mutableItem.save(db)
            }
        } catch {
            print("Failed to save \(error)")
        }
    }

    func saveRecords<T: MutablePersistableRecord>(items: [T]) {
        for item in items {
            do {
                try dbWriter.write { db in
                    var mutableItem = item
                    try mutableItem.save(db)
                }
            } catch {
                print("Failed to save \(error)")
            }
        }
    }


    func fetchRecords<T: FetchableRecord & TableRecord>(type: T.Type) -> [T] {
        do {
            return try dbReader.read { db in
                try T.fetchAll(db)
            }
        } catch {
            print("Database read error: \(error)")
            return []
        }
    }

    func deleteRecord<T: FetchableRecord & TableRecord>(type: T.Type, id: String) {
        do {
            try _ = dbWriter.write { db in
                try T.deleteOne(db, key: id)
            }
        } catch {
            print("Database delete error: \(error)")
        }
    }

    func updateRecord<T: MutablePersistableRecord>(item: T) {
        do {
            try dbWriter.write { db in
                try item.update(db)
            }
        } catch {
            print("Database update error: \(error)")
        }
    }
}

