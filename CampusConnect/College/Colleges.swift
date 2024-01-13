import Foundation
import GRDB
import UIKit

class College: FetchableRecord, MutablePersistableRecord, Codable {
    let id: String  // id is now a String
    var name: String
    var address: String
    var imageData: String? // Stays as String

    // Adjusting the initializer
    init(id: String, name: String, address: String, imageData: String? = nil) {
        self.id = id  // Directly assign the id, no conversion needed
        self.name = name
        self.address = address
        self.imageData = imageData
    }

    static var colleges: [College] = []

    // Function now accepts id as a String
    static func createCollege(id: String, name: String, address: String) throws -> College {
        if colleges.contains(where: { $0.id == id }) {
            throw CollegeError.duplicateCollegeID
        }

        let college = College(id: id, name: name, address: address) // No conversion needed
        colleges.append(college)
        return college
    }

    static func updateCollege(_ college: College, name: String, address: String) {
        college.name = name
        college.address = address
    }

    static func deleteCollege(_ college: College) throws {
        guard let index = colleges.firstIndex(where: { $0 === college }) else {
            throw CollegeError.collegeNotFound
        }

//        if !Program.programs.contains(where: { $0.collegeId == college.id }) {
//            colleges.remove(at: index)
//        } else {
//            throw CollegeError.collegeNotEmpty
//        }
    }

    static func viewAllColleges() {
        print("List of Colleges:")
        for college in colleges {
            print("ID: \(college.id), Name: \(college.name), Address: \(college.address)")
        }
    }

    static func searchColleges(byName name: String) -> [College] {
        return colleges.filter { $0.name.lowercased().contains(name.lowercased()) }
    }
}

extension College {
    // Method signature updated to accept id as a String
    static func updateCollegeAndCascadeChanges(id: String, newName: String?, newAddress: String?) throws {
        guard let collegeIndex = colleges.firstIndex(where: { $0.id == id }) else {
            throw CollegeError.collegeNotFound
        }
        let collegeToUpdate = colleges[collegeIndex]

        if let newName = newName {
            collegeToUpdate.name = newName
        }

        if let newAddress = newAddress {
            collegeToUpdate.address = newAddress
        }

        // Update any associated objects as needed
        // ...
    }
}

enum CollegeError: Error {
    case duplicateCollegeID
    case collegeNotFound
    case collegeNotEmpty
}
