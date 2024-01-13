//
//  CollegeDetailViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//

import UIKit

class CollegeDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var college: College?
    var mainVC: ViewController?
    var vcMode: ViewControllerMode = .create
    
    
    @IBOutlet weak var collegeID: UITextField!
    @IBOutlet weak var collegeName: UITextField!
    @IBOutlet weak var collegeAddress: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if vcMode == .modify {
                guard let mainVC = mainVC, let college = college else { return }
                title = "Update College"
                button.setTitle("Update College", for: .normal)
                collegeID.text = "\(college.id)"
                collegeID.isEnabled = false
                collegeName.text = college.name
                collegeAddress.text = college.address
                if let imageDataString = college.imageData, let imageData = Data(base64Encoded: imageDataString) {
                    imageView.image = UIImage(data: imageData)
                } else {
                    imageView.image = UIImage(named: "placeholder")
                }
            } else {
                title = "Create College"
                button.setTitle("Create College", for: .normal)
                collegeID.isEnabled = true
            }
    }

    
    @IBAction func selectNewImageTap(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                present(imagePickerController, animated: true)
    }
    
    
    @IBAction func createButtonTap(_ sender: Any) {
        if vcMode == .modify {
            updateCollege()
        } else {
            createCollege()
        }
        
    }
    
    func createCollege() {
        guard let mainVC = self.mainVC else { return }

            guard let collegeIdString = collegeID.text, !collegeIdString.isEmpty else {
                self.showAlert(title: "Error", message: "Invalid College Id")
                return
            }
            if mainVC.colleges.contains(where: { $0.id == collegeIdString }) {
                self.showAlert(title: "Error", message: "College id already exists")
                return
            }

            guard let collegeName = collegeName.text, !collegeName.isEmpty else {
                self.showAlert(title: "Error", message: "College name is empty")
                return
            }

            guard let collegeAddress = collegeAddress.text, !collegeAddress.isEmpty else {
                self.showAlert(title: "Error", message: "College address is empty")
                return
            }

            let college = College(id: collegeIdString, name: collegeName, address: collegeAddress)

        
        mainVC.colleges.append(college)
        DatabaseManager.shared.saveRecord(item: college)
        
        self.showAlert(title: "Success", message: "College created successfully")
    }

    func updateCollege() {
        guard let mainVC = mainVC, let updatingCollege = self.college else { return }

        guard let collegeNameText = collegeName.text, !collegeNameText.isEmpty else {
            self.showAlert(title: "Error", message: "College name is empty")
            return
        }
        
        guard let collegeAddressText = collegeAddress.text, !collegeAddressText.isEmpty else {
            self.showAlert(title: "Error", message: "College address is empty")
            return
        }
        
        if let index = mainVC.colleges.firstIndex(where: { $0.id == updatingCollege.id }) {
                    mainVC.colleges[index].name = collegeNameText
                    mainVC.colleges[index].address = collegeAddressText
            if let imageData = imageView.image?.pngData() {
                mainVC.colleges[index].imageData = imageData.base64EncodedString()
            } else {
                mainVC.colleges[index].imageData = nil
            }


                    let updatedCollege = mainVC.colleges[index]
                    DatabaseManager.shared.updateRecord(item: updatedCollege)
                    self.showAlert(title: "Success", message: "College updated successfully")
                } else {
                    self.showAlert(title: "Error", message: "College not found")
                }
    }


    
    
    
    // Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else { return }
            imageView.image = image
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
}
