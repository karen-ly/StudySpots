//
//  ReviewsService.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/28/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import Foundation
import FirebaseFirestore
import CodableFirebase

// Service to manage all the study spot reviews
class ReviewsService {
    // Singleton
    static let shared = ReviewsService()
    
    // Array of all study spot reviews
    var studySpotReviews: [StudySpotReview] = []
    
    // Returns array of study spot reviews from Firestore
    func getStudySpotReviews(onSuccess: @escaping ([StudySpotReview]) -> Void) {
        var allReviews:[StudySpotReview] = []
        // Get all the documents in the study spot reviews collection
        Firestore.firestore().collection("studySpotReviews").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let studySpotReview = try! FirestoreDecoder().decode(StudySpotReview.self, from: document.data())
                    allReviews.append(studySpotReview)
                }
                self.studySpotReviews = allReviews
                onSuccess(self.studySpotReviews)
            }
        }
    }
}
