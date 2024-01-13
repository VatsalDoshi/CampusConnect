import UIKit

class CollegeTableViewController: UITableViewController {

    var mainVC: ViewController?
    let searchController = UISearchController(searchResultsController: nil)
    var colleges: [College] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Colleges"

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
        colleges = mainVC?.colleges ?? []
        //       colleges = DatabaseManager.shared.fetchRecords(type: College.self)
        tableView.reloadData()
    }

    @objc func addTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CollegeDetailViewController") as? CollegeDetailViewController {
            vc.mainVC = mainVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colleges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CollegeCell")

            if let imageUrlString = colleges[indexPath.row].imageData, let url = URL(string: imageUrlString) {
                // Download and set the image from URL
                downloadImage(from: url) { image in
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.setNeedsLayout() // Needed to update the cell layout after image load
                    }
                }
            } else {
                cell.imageView?.image = UIImage(named: "placeholder")
            }
            
            cell.textLabel?.text = colleges[indexPath.row].name
            cell.detailTextLabel?.text = colleges[indexPath.row].address
            return cell
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CollegeDetailViewController") as? CollegeDetailViewController {
            vc.mainVC = mainVC
            vc.vcMode = .modify
            vc.college = mainVC?.colleges[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let mainVC = mainVC {
            let collegeId = mainVC.colleges[indexPath.row].id

            // Check if the college is being used in any courses or programs
            let isCollegeUsed = mainVC.courses.contains(where: { $0.collegeId == collegeId }) || mainVC.programs.contains(where: { $0.collegeId == collegeId })

            if isCollegeUsed {
                showAlert(title: "Cannot Delete", message: "This college is being used in a course or program.")
            } else {
                // College is not being used, safe to delete
                let college = mainVC.colleges[indexPath.row]
                DatabaseManager.shared.deleteRecord(type: College.self, id: college.id)
                
                // Remove the college from the array
                mainVC.colleges.remove(at: indexPath.row)

                // Update the colleges array in the current view controller
                colleges = mainVC.colleges

                // Now delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Code for inserting a new college
        }
    }



    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension CollegeTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, let mainVC = mainVC else { return }
        
        if text.isEmpty {
            colleges = mainVC.colleges ?? []
        } else {
            colleges = mainVC.colleges.filter( {
                $0.name.lowercased().contains(text.lowercased()) ||
                String($0.id).lowercased().contains(text.lowercased()) } )
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension CollegeTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.colleges = self.mainVC?.colleges ?? []
            self.tableView.reloadData()
        }
    }
}
