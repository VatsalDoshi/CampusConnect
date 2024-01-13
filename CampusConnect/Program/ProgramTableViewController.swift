import UIKit

class ProgramTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var mainVC: ViewController? 
    let searchController = UISearchController(searchResultsController: nil)
    var programs: [Program] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Programs"

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
        // Fetch programs from the database or your main view controller
        programs = mainVC?.programs ?? DatabaseManager.shared.fetchRecords(type: Program.self)
        tableView.reloadData()
    }

    @objc func addTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProgramDetailsViewController") as? ProgramDetailsViewController {
            vc.mainVC = mainVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramCell", for: indexPath)
        let program = programs[indexPath.row]
        cell.textLabel?.text = program.name
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProgramDetailsViewController") as? ProgramDetailsViewController {
            vc.program = programs[indexPath.row]
            vc.mainVC = mainVC
            vc.vcMode = .modify // Assuming you have a mode to differentiate between add and edit
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let mainVC = mainVC {
            let programToDelete = programs[indexPath.row]

            // Check if the program is being used in any courses
            let isProgramUsed = mainVC.courses.contains(where: { $0.programId == programToDelete.id })

            if isProgramUsed {
                showAlert(title: "Cannot Delete", message: "This program is being used in a course.")
            } else {
                // Delete the program
                DatabaseManager.shared.deleteRecord(type: Program.self, id: String(programToDelete.id))

                // Update the data source
                programs.remove(at: indexPath.row)
                mainVC.programs = programs

                // Update the UI
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if text.isEmpty {
            programs = mainVC?.programs ?? []
        } else {
            programs = mainVC?.programs.filter {
                $0.name.lowercased().contains(text.lowercased())
            } ?? []
        }
        tableView.reloadData()
    }

    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.programs = self.mainVC?.programs ?? []
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
