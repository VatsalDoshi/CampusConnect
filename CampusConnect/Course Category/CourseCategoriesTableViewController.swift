import UIKit

class CourseCategoriesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var mainVC: ViewController?
    let searchController = UISearchController(searchResultsController: nil)
    var categories: [CourseCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Course Categories"

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
        categories = mainVC?.courseCategories ?? []
        tableView.reloadData()
    }

    @objc func addTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CourseCategoriesDetailVC") as? CourseCategoriesDetailViewController {
            vc.mainVC = mainVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CourseCategoriesDetailVC") as? CourseCategoriesDetailViewController {
            vc.mainVC = mainVC
            vc.category = mainVC?.courseCategories[indexPath.row]
            vc.vcMode = .modify
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let mainVC = mainVC {
            let categoryToDelete = categories[indexPath.row]

            // Check if the category is being used in any courses
            let isCategoryUsed = mainVC.courses.contains(where: { $0.courseCategoryId == categoryToDelete.id })

            if isCategoryUsed {
                showAlert(title: "Cannot Delete", message: "This category is being used in a course.")
            } else {
                // Delete the category
                DatabaseManager.shared.deleteRecord(type: CourseCategory.self, id: String(categoryToDelete.id))

                // Update the data source
                categories.remove(at: indexPath.row)
                mainVC.courseCategories = categories

                // Update the UI
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }


    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if text.isEmpty {
            categories = mainVC?.courseCategories ?? []
        } else {
            categories = mainVC?.courseCategories.filter {
                $0.name.lowercased().contains(text.lowercased())
            } ?? []
        }
        tableView.reloadData()
    }

    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.categories = self.mainVC?.courseCategories ?? []
            self.tableView.reloadData()
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
