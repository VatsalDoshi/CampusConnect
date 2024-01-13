//
//  CourseTableViewController.swift
//  Assignment 9 Storyboard
//
//  Created by Vatsal Doshi on 11/17/23.
//
import UIKit

class CourseTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var mainVC: ViewController? // Replace with the actual type of your main view controller
    let searchController = UISearchController(searchResultsController: nil)
    var courses: [Course] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Courses"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
        self.navigationItem.rightBarButtonItem = addButton

        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type to search"
        navigationItem.searchController = searchController

      
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Assuming fetchRecords(type:) returns [Course]
        courses = DatabaseManager.shared.fetchRecords(type: Course.self) 
        tableView.reloadData()
    }



    @objc func addTapped(_ sender: Any) {
        mainVC?.refreshData()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let courseDetailsVC = storyboard.instantiateViewController(withIdentifier: "CourseDetailViewController") as? CourseDetailViewController {
            courseDetailsVC.mainVC = mainVC
            //courseDetailsVC.vcMode = .create
            self.navigationController?.pushViewController(courseDetailsVC, animated: true)
        }
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        let course = courses[indexPath.row]
        cell.textLabel?.text = course.name
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let courseDetailsVC = storyboard.instantiateViewController(withIdentifier: "CourseDetailViewController") as? CourseDetailViewController {
            courseDetailsVC.course = courses[indexPath.row]
            courseDetailsVC.mainVC = mainVC
            courseDetailsVC.vcMode = .modify
            self.navigationController?.pushViewController(courseDetailsVC, animated: true)
        }
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let courseToDelete = courses[indexPath.row]

            // Check if the course is being used in any other entities
            let isCourseUsed = checkIfCourseIsUsed(courseId: courseToDelete.id)

            if isCourseUsed {
                showAlert(title: "Cannot Delete", message: "This course is being used and cannot be deleted.")
            } else {
                // Delete the course
                DatabaseManager.shared.deleteRecord(type: Course.self, id: String(courseToDelete.id))

                // Update the data source
                courses.remove(at: indexPath.row)

                // Update the UI
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    private func checkIfCourseIsUsed(courseId: Int) -> Bool {
        // Example logic to check if the course is being used

        // Check if the course is associated with any program
        let isCourseInProgram = Program.programs.contains { program in
            program.id == courseId
        }

        // Check if the course is associated with any college
//        let isCourseInCollege = College.colleges.contains { college in
//            college.id == courseId
//        }

        // Check if the course is associated with any course category
        let isCourseInCategory = CourseCategory.categories.contains { category in
            category.id == courseId
        }

        return isCourseInProgram || isCourseInCategory
    }



    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if text.isEmpty {
            courses = mainVC?.courses ?? []
        } else {
            courses = mainVC?.courses.filter {
                $0.name.lowercased().contains(text.lowercased())
            } ?? []
        }
        tableView.reloadData()
    }

    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.courses = self.mainVC?.courses ?? []
            self.tableView.reloadData()
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
