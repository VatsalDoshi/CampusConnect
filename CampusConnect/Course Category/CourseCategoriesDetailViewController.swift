//
//  CourseCategoriesDetailViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//

import UIKit

class CourseCategoriesDetailViewController: UIViewController {

    var category: CourseCategory?
    var mainVC: ViewController?
    var vcMode: ViewControllerMode = .create

    var indexPath: IndexPath?
    @IBOutlet weak var categoryIdTextField: UITextField!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var createUpdateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if vcMode == .modify {
            guard let mainVC = mainVC, let category = category else { return }
            title = "Update Course Category"
            createUpdateButton.setTitle("Update Category", for: .normal)
            categoryIdTextField.text = "\(category.id)"
            categoryIdTextField.isEnabled = false
            categoryNameTextField.text = category.name
        } else {
            title = "Create Course Category"
            createUpdateButton.setTitle("Create Category", for: .normal)
            categoryIdTextField.isEnabled = true
        }
    }

    @IBAction func createUpdateButtonTapped(_ sender: Any) {
        if vcMode == .modify {
            updateCategory()
        } else {
            createCategory()
        }
    }

    private func createCategory() {
        guard let mainVC = self.mainVC else { return }

        guard let categoryId = Int(categoryIdTextField.text ?? "0") else {
            showAlert(title: "Error", message: "Invalid Category Id")
            return
        }
        if mainVC.courseCategories.contains(where: {$0.id == categoryId}) {
            showAlert(title: "Error", message: "Category id already exists")
            return
        }

        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else {
            showAlert(title: "Error", message: "Category name is empty")
            return
        }

        let category = CourseCategory(id: categoryId, name: categoryName)
        mainVC.courseCategories.append(category)
        DatabaseManager.shared.saveRecord(item: category)
        showAlert(title: "Success", message: "Category created successfully")
    }

    private func updateCategory() {
        guard let mainVC = mainVC, let updatingCategory = self.category else { return }

        guard let categoryNameText = categoryNameTextField.text, !categoryNameText.isEmpty else {
            showAlert(title: "Error", message: "Category name is empty")
            return
        }

        if let index = mainVC.courseCategories.firstIndex(where: { $0.id == updatingCategory.id }) {
            mainVC.courseCategories[index].name = categoryNameText

            let updatedCategory = mainVC.courseCategories[index]
            DatabaseManager.shared.updateRecord(item: updatedCategory)
            showAlert(title: "Success", message: "Category updated successfully")
        } else {
            showAlert(title: "Error", message: "Category not found")
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}

