//
//  User.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/28/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import Foundation
import FirebaseAuth

// Represents current user and manages login status
class User {
    // Singleton
    static let shared = User()
    var userID = ""
    var loggedIn = false
    
    // Sets user as logged in and saves user id
    func login(userID_: String) {
        userID = userID_
        loggedIn = true
    }
    
    // Sets user as logged out
    func logout() {
        loggedIn = false
    }
    
    // Checks if user is already logged in or not
    func isLoggedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser {
            loggedIn = true
            userID = currentUser.uid
            return true
        }
        if loggedIn {
            return true
        }
        return false
    }
}
