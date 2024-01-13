//
//  ProgramDetailsViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//

import UIKit

class ProgramDetailsViewController: UIViewController {
    var program: Program?
    var mainVC: ViewController?
    var vcMode: ViewControllerMode = .create
    
    @IBOutlet weak var programIdTextField: UITextField!
    @IBOutlet weak var collegeIdTextField: UITextField!
    @IBOutlet weak var programNameTextField: UITextField!
    @IBOutlet weak var createUpdateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if vcMode == .modify {
                guard let program = program else { return }
                title = "Update Program"
                createUpdateButton.setTitle("Update Program", for: .normal)
                programIdTextField.text = "\(program.id)"
                programIdTextField.isEnabled = false
                programNameTextField.text = program.name
                collegeIdTextField.text = "\(program.collegeId)"
            } else {
                title = "Create Program"
                createUpdateButton.setTitle("Create Program", for: .normal)
                programIdTextField.isEnabled = true
            }
        }

    @IBAction func createUpdateButtonTapped(_ sender: Any) {
            if vcMode == .modify {
                updateProgram()
            } else {
                createProgram()
            }
        }

    private func createProgram() {
            // Debugging: Print the current list of college IDs
            print("Available College IDs: \(mainVC?.colleges.map { $0.id } ?? [])")

            guard let programId = Int(programIdTextField.text ?? ""),
                  let collegeId = Int(collegeIdTextField.text ?? ""),
                  let programName = programNameTextField.text, !programName.isEmpty else {
                showAlert(title: "Error", message: "Invalid input")
                return
            }

            guard mainVC?.programs.contains(where: { $0.id == programId }) == false else {
                showAlert(title: "Error", message: "Program ID already exists")
                return
            }

        guard let collegeIdString = collegeIdTextField.text,
                  !collegeIdString.isEmpty,
                  mainVC?.colleges.contains(where: { $0.id == collegeIdString }) == true else {
                showAlert(title: "Error", message: "College not found for the given ID")
                return
            }

            do {
                let newProgram = try Program.createProgram(id: programId, name: programName, collegeId: collegeIdString, colleges: mainVC?.colleges ?? [])
                mainVC?.programs.append(newProgram)
                DatabaseManager.shared.saveRecord(item: newProgram)
                showAlert(title: "Success", message: "Program created successfully")
            } catch let error as ProgramError {
                switch error {
                case .duplicateProgramID:
                    showAlert(title: "Error", message: "Duplicate program ID.")
                case .collegeNotFound:
                    showAlert(title: "Error", message: "College not found for the given ID.")
                case .programNotEmpty:
                    showAlert(title: "Error", message: "Program not empty.")
                case .programNotFound:
                    showAlert(title: "Error", message: "Program not found.")
                }
            } catch {
                showAlert(title: "Error", message: "An unknown error occurred: \(error.localizedDescription)")
            }
        }

    private func updateProgram() {
        guard let mainVC = mainVC,
              let updatingProgram = self.program,
              let indexPath = mainVC.programs.firstIndex(where: { $0.id == updatingProgram.id }) else { return }

        // Validate program name input
        guard let programName = programNameTextField.text, !programName.isEmpty else {
            showAlert(title: "Error", message: "Program name is empty")
            return
        }

        // Validate college ID input
        guard let collegeIdString = collegeIdTextField.text,
                  !collegeIdString.isEmpty,
                  mainVC.colleges.contains(where: { $0.id == collegeIdString }) else {
                showAlert(title: "Error", message: "Invalid or nonexistent college ID")
                return
            }

            // Update the program
            mainVC.programs[indexPath].name = programName
            mainVC.programs[indexPath].collegeId = collegeIdString
        

        let updatedProgram = mainVC.programs[indexPath]

        // Update record in the database
        DatabaseManager.shared.updateRecord(item: updatedProgram)

        showAlert(title: "Success", message: "Program updated successfully")
    }






        private func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
        }
    }
