//
//  FavoritesTableViewController.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/23/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import UIKit

// View Controller for displaying favorite study spots
class FavoritesTableViewController: UITableViewController {
    private var studySpotsService = StudySpotsService.shared
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Set UI for edit button and title
    override func viewDidLoad() {
        editButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Avenir Next Medium", size: 18)!,
            NSAttributedString.Key.foregroundColor : UIColor.tintColor,
        ], for: .normal)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Next Medium", size: 20)!]
    }
    
    // Load all the favorite study spots
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isEditing = false
        editButton.title = "Edit"
        // Get all favorites from Firestore and reloads the table
        loadFavoriteStudySpots()
    }

    // Returns number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Return the number of rows in the section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studySpotsService.favList.favStudySpots.count
    }
    
    // Configures each study spot cell to show name and address
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteSpotTableCell", for: indexPath)
        // Configure the cell...
        let studySpot = studySpotsService.favList.favStudySpots[indexPath.row]
        cell.textLabel?.text = studySpot.name
        cell.detailTextLabel?.text = studySpot.address.getAddress()
        return cell
    }
    
    // Loads favorite study spots from Firestore
    func loadFavoriteStudySpots() {
        // When finished, it should reload the table view on the main thread
        studySpotsService.getFavStudySpots { studySpots in
            // Execute updating the user interface in main thread
            DispatchQueue.main.async {
                // Reload the collection view on the main thread
                self.tableView.reloadData()
            }
        }
    }

    // Allows editing to delete study spots
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from the underlying data source
            studySpotsService.favList.favStudySpots.remove(at: indexPath.row)
            studySpotsService.uploadFavStudySpots()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Toggles editing mode 
    @IBAction func editDidTapped(_ sender: UIBarButtonItem) {
        // If table view is in editing mode, then turn off editing mode
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
        }
        // Else if not editing mode, then turn on editing mode
        else {
            tableView.isEditing = true
            sender.title = "Done"
        }
    }
}
