//
//  ViewController.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/17/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// View Controller for Sign In Screen
class SignInViewController: UIViewController {
    let signInConfig = GIDConfiguration(clientID: "121677907521-vtfdtaiuejtqtgvku810rpqp3ppc509c.apps.googleusercontent.com")
    
    // Check if user is already logged in. If so, then skip sign in.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If there is already a current user, then move immediately to reviews view controller
        if User.shared.isLoggedIn() {
            self.performSegue(withIdentifier: "authSegue", sender: nil)
        }
    }
    
    // Launch Google Sign-In flow and login with Firebase Auth
    @IBAction func signInDidTapped(_ sender: Any) {
        // Use Google Sign-In API as a third party API for authentication
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            // Google Sign-In failed
            guard error == nil else { return }
            guard let user = user else { return }
            
            // After user successfully signs in, get the user's ID token for Firebase Auth
            user.authentication.do { authentication, error in
                // Unable to get authentication credentials
                guard error == nil else { return }
                guard let authentication = authentication else { return }

                // Send user's ID token to Firebase Auth to track account
                let authcred: AuthCredential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                // Sign in with Firebase Auth
                Auth.auth().signIn(with: authcred, completion: {(result, error) in
                    // If no errors, then successful login with Firebase Auth and show reviews
                    if error == nil {
                        // Keep track of the logged in user
                        User.shared.login(userID_: result?.user.uid ?? "")
                        self.performSegue(withIdentifier: "authSegue", sender: nil)
                    }
                })
            }
        }
    }
}

