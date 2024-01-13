//
//  CourseCategories.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//

import Foundation
import GRDB

// CourseCategory.swift
class CourseCategory: FetchableRecord, MutablePersistableRecord, Codable  {
    let id: Int
    var name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    // CRUD operations for CourseCategory
    static var categories: [CourseCategory] = []

    static func createCategory(id: Int, name: String) throws -> CourseCategory {
        // Check if a category with the same ID already exists
        if categories.contains(where: { $0.id == id }) {
            throw CourseCategoryError.duplicateCategoryID
        }

        let category = CourseCategory(id: id, name: name)
        categories.append(category)
        return category
    }

    static func updateCategory(_ category: CourseCategory, name: String) {
        category.name = name
    }

    static func deleteCategory(_ category: CourseCategory) throws {
        guard let index = categories.firstIndex(where: { $0 === category }) else {
            throw CourseCategoryError.categoryNotFound
        }

        // Check if the category is not associated with any course
        if !Course.courses.contains(where: { $0.courseCategoryId == category.id }) {
            categories.remove(at: index)
        } else {
            throw CourseCategoryError.categoryNotEmpty
        }
    }
    static func viewAllCourseCategories() {
        print("List of Course Categories:")
        for category in categories {
            print("ID: \(category.id), Name: \(category.name)")
        }
    }
    
    static func searchCategories(byName name: String) -> [CourseCategory] {
        return categories.filter { $0.name.lowercased().contains(name.lowercased()) }
    }

}

enum CourseCategoryError: Error {
    case duplicateCategoryID
    case categoryNotFound
    case categoryNotEmpty
}


