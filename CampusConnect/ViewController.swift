//
//  ViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//

import UIKit

class ViewController: UIViewController {
    
    var colleges: [College] = []
    var programs: [Program] = []
    var courses: [Course] = []
    var courseCategories: [CourseCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Main Menu"
        navigationController?.navigationBar.prefersLargeTitles = false
        // addDataToDB()
        // generateDBdata()
        fetchDataFromAPI()
    }
    
//    func generateDBdata() {
//        colleges = DatabaseManager.shared.fetchRecords(type: College.self)
//        programs = DatabaseManager.shared.fetchRecords(type: Program.self)
//        courses = DatabaseManager.shared.fetchRecords(type: Course.self)
//        courseCategories = DatabaseManager.shared.fetchRecords(type: CourseCategory.self)
//    }
    func fetchDataFromAPI() {
        APIUtils.shared.getAllColleges() { colleges in
            self.colleges = colleges
        }

        DatabaseManager.shared.saveRecords(items: colleges)
    }

//        func generateDummyData() {
//            // Create colleges
//            let college1 = College(id: 1, name: "College of Engineering", address: "360 Huntington")
//            let college2 = College(id: 2, name: "College of Professional Studies", address: "380 Huntington")
//            College.colleges.append(contentsOf: [college1, college2])
//            
//            // Create course categories
//            let categoryInfo = CourseCategory(id: 1, name: "INFO")
//            let categoryCyse = CourseCategory(id: 2, name: "CYSE")
//            CourseCategory.categories.append(contentsOf: [categoryInfo, categoryCyse])
//            
//            // Create programs
//            let programIS = Program(id: 1, name: "Information Systems", collegeId: 1)
//            let programSE = Program(id: 2, name: "Software Engineering", collegeId: 2)
//            Program.programs.append(contentsOf: [programIS, programSE])
//            
//            // Create courses
//            let courseSmartphone = Course(id: 1, name: "Smartphone Based Web Development", collegeId: 1, programId: 1, courseCategoryId: 1)
//            let courseWebDev = Course(id: 2, name: "PSA", collegeId: 1, programId: 1, courseCategoryId: 2)
//            let courseAED = Course(id: 3, name: "DMDD", collegeId: 2, programId: 2, courseCategoryId: 1)
//            let courseDatabase = Course(id: 4, name: "Database", collegeId: 2, programId: 2, courseCategoryId: 2)
//            Course.courses.append(contentsOf: [courseSmartphone, courseWebDev, courseAED, courseDatabase])
//            
//            
//            DatabaseManager.shared.saveRecord(college1)
//            DatabaseManager.shared.saveRecord(college2)
//            DatabaseManager.shared.saveRecord(categoryInfo)
//            DatabaseManager.shared.saveRecord(categoryCyse)
//            DatabaseManager.shared.saveRecord(programIS)
//            DatabaseManager.shared.saveRecord(programSE)
//            DatabaseManager.shared.saveRecord(courseSmartphone)
//            DatabaseManager.shared.saveRecord(courseWebDev)
//            DatabaseManager.shared.saveRecord(courseAED)
//            DatabaseManager.shared.saveRecord(courseDatabase)
//        }
    
    func refreshData() {
        colleges = DatabaseManager.shared.fetchRecords(type: College.self)
        programs = DatabaseManager.shared.fetchRecords(type: Program.self)
        courses = DatabaseManager.shared.fetchRecords(type: Course.self)
        courseCategories = DatabaseManager.shared.fetchRecords(type: CourseCategory.self)
    }

        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? CollegeTableViewController {
                vc.mainVC = self
            }
            if let vc = segue.destination as? CourseCategoriesTableViewController {
                vc.mainVC = self
            }
            if let vc = segue.destination as? ProgramTableViewController {
                vc.mainVC = self
            }
            if let vc = segue.destination as? CourseTableViewController {
                vc.mainVC = self
            }
        }
    }

enum ViewControllerMode {
    case create, modify
}
