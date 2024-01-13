import Foundation
import GRDB

class Program: FetchableRecord, MutablePersistableRecord, Codable  {
    let id: Int
    var name: String
    var collegeId: String  // collegeId is a String

    init(id: Int, name: String, collegeId: String) {  // Changed collegeId parameter to String
        self.id = id
        self.name = name
        self.collegeId = collegeId
    }

    static var programs: [Program] = []

    static func createProgram(id: Int, name: String, collegeId: String, colleges: [College]) throws -> Program {
        if programs.contains(where: { $0.id == id }) {
            throw ProgramError.duplicateProgramID
        }

        if !colleges.contains(where: { $0.id == collegeId }) {  // collegeId is now a String
            throw ProgramError.collegeNotFound
        }

        let program = Program(id: id, name: name, collegeId: collegeId)
        programs.append(program)
        return program
    }

    static func updateProgram(_ program: Program, name: String) {
        program.name = name
    }

    static func deleteProgram(_ program: Program) throws {
        guard let index = programs.firstIndex(where: { $0 === program }) else {
            throw ProgramError.programNotFound
        }

        if !Course.courses.contains(where: { $0.programId == program.id }) {
            programs.remove(at: index)
        } else {
            throw ProgramError.programNotEmpty
        }
    }
    
    static func viewAllPrograms() -> String {
        return programs.map { "ID: \($0.id), Name: \($0.name), College ID: \($0.collegeId)" }.joined(separator: "\n")
    }

    static func searchPrograms(byName name: String) -> [Program] {
        return programs.filter { $0.name.lowercased().contains(name.lowercased()) }
    }
}

extension Program {
    static func updateProgramAndCascadeChanges(id: Int, newName: String?, newCollegeId: String?) throws {
        guard let programIndex = programs.firstIndex(where: { $0.id == id }) else {
            throw ProgramError.programNotFound
        }
        let programToUpdate = programs[programIndex]

        if let newName = newName {
            programToUpdate.name = newName
        }

        if let newCollegeId = newCollegeId, programToUpdate.collegeId != newCollegeId {
            guard College.colleges.contains(where: { $0.id == newCollegeId }) else {
                throw ProgramError.collegeNotFound
            }
            programToUpdate.collegeId = newCollegeId

            Course.courses.filter { $0.programId == id }.forEach { course in
                course.collegeId = newCollegeId  // Assuming course.collegeId is also a String
            }
        }
    }
}

enum ProgramError: Error {
    case duplicateProgramID
    case programNotFound
    case programNotEmpty
    case collegeNotFound
}
