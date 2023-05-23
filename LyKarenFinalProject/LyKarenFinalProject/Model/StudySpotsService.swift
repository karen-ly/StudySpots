//
//  StudySpotsService.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/30/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import Foundation
import FirebaseFirestore
import CodableFirebase

// Service to manage all study spots
class StudySpotsService {
    // Singleton
    static let shared = StudySpotsService()
    
    // Contains all of user's favorite study spots
    var favList: FavoriteStudySpots = FavoriteStudySpots(favStudySpots: [])

    // Retrieve all the current user's favorite study spots from Firestore
    func getFavStudySpots(onSuccess: @escaping (FavoriteStudySpots) -> Void) {
        // Get the document corresponding to user id
        let favRef = Firestore.firestore().collection("favorites").document("\(User.shared.userID)")
        favRef.getDocument { (document, error) in
            if let document = document {
                // If document exists, then fill in the array of favorites
                if document.exists {
                    self.favList = try! FirestoreDecoder().decode(FavoriteStudySpots.self, from: document.data()!)
                    onSuccess(self.favList)
                }
                // Else document does not exists, then return empty
                else {
                    onSuccess(self.favList)
                }
            }
        }
    }
    
    // Update the favorite array stored in Firestore
    func uploadFavStudySpots() {
        let favData = try! FirestoreEncoder().encode(favList)
        Firestore.firestore().collection("favorites").document("\(User.shared.userID)").setData(favData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
