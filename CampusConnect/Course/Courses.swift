import Foundation
import GRDB

class Course: FetchableRecord, MutablePersistableRecord, Codable {
    let id: Int
    var name: String
    var collegeId: String  // collegeId is now a String
    var programId: Int
    var courseCategoryId: Int

    init(id: Int, name: String, collegeId: String, programId: Int, courseCategoryId: Int) {
        self.id = id
        self.name = name
        self.collegeId = collegeId
        self.programId = programId
        self.courseCategoryId = courseCategoryId
    }

    static var courses: [Course] = []

    static func createCourse(id: Int, name: String, collegeId: String, programId: Int, courseCategoryId: Int) throws -> Course {
        if courses.contains(where: { $0.id == id }) {
            throw CourseError.duplicateCourseID
        }

        if !College.colleges.contains(where: { $0.id == collegeId }) {
            throw CourseError.collegeNotFound
        }

        if !Program.programs.contains(where: { $0.id == programId }) {
            throw CourseError.programNotFound
        }

        if !CourseCategory.categories.contains(where: { $0.id == courseCategoryId }) {
            throw CourseError.courseCategoryNotFound
        }

        let course = Course(id: id, name: name, collegeId: collegeId, programId: programId, courseCategoryId: courseCategoryId)
        courses.append(course)
        return course
    }

    static func updateCourse(_ course: Course, newName: String, newCollegeId: String, newProgramId: Int, newCourseCategoryId: Int) {
        course.name = newName
        course.collegeId = newCollegeId  // collegeId is a String
        course.programId = newProgramId
        course.courseCategoryId = newCourseCategoryId
    }

    static func deleteCourse(_ course: Course) throws {
        guard let index = courses.firstIndex(where: { $0 === course }) else {
            throw CourseError.courseNotFound
        }
        courses.remove(at: index)
    }
    
    static func viewAllCourses() -> String {
        return courses.map { "ID: \($0.id), Name: \($0.name), College ID: \($0.collegeId), Program ID: \($0.programId), Category ID: \($0.courseCategoryId)" }.joined(separator: "\n\n")
    }

    static func searchCourses(byName name: String) -> [Course] {
        return courses.filter { $0.name.lowercased().contains(name.lowercased()) }
    }
}

extension Course {
    static func updateCourseAndCascadeChanges(id: Int, newName: String?, newCollegeId: String?, newProgramId: Int?, newCourseCategoryId: Int?) throws {
        guard let courseIndex = courses.firstIndex(where: { $0.id == id }) else {
            throw CourseError.courseNotFound
        }
        let courseToUpdate = courses[courseIndex]

        if let newName = newName {
            courseToUpdate.name = newName
        }
        if let newCollegeId = newCollegeId {
            courseToUpdate.collegeId = newCollegeId
        }
        if let newProgramId = newProgramId {
            courseToUpdate.programId = newProgramId
        }
        if let newCourseCategoryId = newCourseCategoryId {
            courseToUpdate.courseCategoryId = newCourseCategoryId
        }

        // Additional logic for cascading changes if necessary
    }
}

enum CourseError: Error {
    case duplicateCourseID
    case courseNotFound
    case collegeNotFound
    case programNotFound
    case courseCategoryNotFound
}
