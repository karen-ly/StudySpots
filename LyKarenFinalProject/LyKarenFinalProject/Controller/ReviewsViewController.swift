//
//  ReviewsViewController.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/20/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import UIKit
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn

// View Controller for displaying all study spot reviews 
class ReviewsViewController: UIViewController, UITableViewDataSource {
    private var reviewsService = ReviewsService.shared
    
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var addReviewButton: UIButton!
    
    // Prepare UI of content
    override func viewDidLoad() {
        super.viewDidLoad()
        // Allow dynamically resizing for table view
        reviewsTableView.rowHeight = UITableView.automaticDimension
        reviewsTableView.estimatedRowHeight = 500
        // Format logout button
        logoutButton.layer.cornerRadius = 5
        logoutButton.clipsToBounds = true
        logoutButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 15)
        // Format add review button
        addReviewButton.configuration?.attributedTitle?.font = UIFont(name: "Avenir Next Medium", size: 18)
    }
    
    // Reload reviews and update button UI
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load in reviews
        loadReviews()
    }
    
    // Return the number of rows in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsService.studySpotReviews.count
    }
    
    // Returns the configured cell which contains photo and study spot review details
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewTableCell", for: indexPath) as! ReviewTableViewCell
        // Don't need cell to be selectable
        reviewCell.selectionStyle = .none
        // Configure the cell...
        let studySpotReview = reviewsService.studySpotReviews[indexPath.row]
        let studySpot = studySpotReview.studySpot
        reviewCell.nameLabel.text = "\(studySpot.name)"
        reviewCell.addressLabel.text = "\(studySpot.address.getAddress())"
        reviewCell.descriptionLabel.text = "\(studySpotReview.description)"

        // Create URL for image
        guard let url = URL(string: studySpotReview.imageURL) else {
            // If couldn't get image, then use default placeholder image
            reviewCell.studySpotImageView.image = UIImage(named: "imagePlaceholder")
            return reviewCell
        }
        // Download image from Storage
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            // If able to get image, then update image view in main thread
            if data != nil && error == nil {
                DispatchQueue.main.async {
                    let image = UIImage(data: data!)
                    reviewCell.studySpotImageView.image = image
                }
            }
            // If couldn't get image, then use default placeholder image
            else {
                reviewCell.studySpotImageView.image = UIImage(named: "imagePlaceholder")
            }
        })
        // Run the task
        task.resume()
        return reviewCell
    }
    
    // Move to add review screen
    @IBAction func addReviewDidTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addReviewSegue", sender: nil)
    }
    
    // Invokes the ReviewsService.shared.getStudySpotReviews(…) method to get all reviews from Firestore
    func loadReviews() {
        // After getting reviews, reload the table view on the main thread
        reviewsService.getStudySpotReviews { reviews in
            // Execute updating the user interface in main thread
            DispatchQueue.main.async {
                self.reviewsTableView.reloadData()
            }
        }
    }
    
    // Sign out user from Google Sign-In and Auth and go back to Sign In screen
    @IBAction func logoutDidTapped(_ sender: UIButton) {
        // Sign out of account associated with Google Sign In
        GIDSignIn.sharedInstance.signOut()
        // Sign out current user of Firebase Auth
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        User.shared.logout()
        dismiss(animated: true)
    }
}
