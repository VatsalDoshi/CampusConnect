//
//  CourseDetailViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//
import UIKit

class CourseDetailViewController: UIViewController {
    
    var course: Course?
    var mainVC: ViewController?
    var vcMode: ViewControllerMode = .create

     @IBOutlet weak var courseIdTextField: UITextField!
     @IBOutlet weak var courseNameTextField: UITextField!
     @IBOutlet weak var collegeIdTextField: UITextField!
     @IBOutlet weak var programIdTextField: UITextField!
     @IBOutlet weak var courseCategoryIdTextField: UITextField!
     @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
            super.viewDidLoad()
            // Additional setup after loading the view
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if vcMode == .modify {
                guard let course = course else { return }
                title = "Update Course"
                saveButton.setTitle("Update Course", for: .normal)
                courseIdTextField.text = "\(course.id)"
                courseIdTextField.isEnabled = false
                courseNameTextField.text = course.name
                collegeIdTextField.text = "\(course.collegeId)"
                programIdTextField.text = "\(course.programId)"
                courseCategoryIdTextField.text = "\(course.courseCategoryId)"
            } else {
                title = "Create Course"
                saveButton.setTitle("Create Course", for: .normal)
                courseIdTextField.isEnabled = true
            }
        }

    @IBAction func saveButtonTapped(_ sender: Any) {
    
        if vcMode == .modify {
            updateCourse()
        } else {
            createCourse()
        }
    }

    private func createCourse() {
            guard let courseId = Int(courseIdTextField.text ?? ""),
                  let collegeId = Int(collegeIdTextField.text ?? ""),
                  let programId = Int(programIdTextField.text ?? ""),
                  let courseCategoryId = Int(courseCategoryIdTextField.text ?? ""),
                  let courseName = courseNameTextField.text, !courseName.isEmpty else {
                showAlert(title: "Error", message: "Invalid input")
                return
            }

            guard mainVC?.courses.contains(where: { $0.id == courseId }) == false else {
                showAlert(title: "Error", message: "Course ID already exists")
                return
            }
        guard let collegeIdString = collegeIdTextField.text,
                  !collegeIdString.isEmpty else {
                showAlert(title: "Error", message: "Invalid College ID")
                return
            }

        do {
                let newCourse = try Course.createCourse(id: courseId, name: courseName, collegeId: collegeIdString, programId: programId, courseCategoryId: courseCategoryId)
                mainVC?.courses.append(newCourse)
                DatabaseManager.shared.saveRecord(item: newCourse)
                showAlert(title: "Success", message: "Course created successfully")
            } catch let error as CourseError {
                handleCourseError(error)
            } catch {
                showAlert(title: "Error", message: "An unknown error occurred: \(error.localizedDescription)")
            }
        }

    private func updateCourse() {
        guard let updatingCourse = self.course,
              let courseName = courseNameTextField.text, !courseName.isEmpty else {
            showAlert(title: "Error", message: "Invalid input")
            return
        }

        updatingCourse.name = courseName
        // Update other properties if necessary
        // Assuming collegeId, programId, and courseCategoryId can also be updated
        guard let collegeIdString = collegeIdTextField.text,
                  !collegeIdString.isEmpty else {
                showAlert(title: "Error", message: "Invalid College ID")
                return
            }
        if let collegeId = Int(collegeIdTextField.text ?? ""),
           let programId = Int(programIdTextField.text ?? ""),
           let courseCategoryId = Int(courseCategoryIdTextField.text ?? "") {
            updatingCourse.collegeId = collegeIdString
            updatingCourse.programId = programId
            updatingCourse.courseCategoryId = courseCategoryId
        } else {
            showAlert(title: "Error", message: "Invalid IDs")
            return
        }

        DatabaseManager.shared.updateRecord(item: updatingCourse)
        showAlert(title: "Success", message: "Course updated successfully")
    }

        private func handleCourseError(_ error: CourseError) {
            var errorMessage = ""
            switch error {
            case .duplicateCourseID:
                errorMessage = "Duplicate course ID."
            case .collegeNotFound:
                errorMessage = "College not found for the given ID."
            case .programNotFound:
                errorMessage = "Program not found for the given ID."
            case .courseCategoryNotFound:
                errorMessage = "Course category not found for the given ID."
            case .courseNotFound:
                errorMessage = "Course not found."
            }
            showAlert(title: "Error", message: errorMessage)
        }

        private func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
        }
    }
