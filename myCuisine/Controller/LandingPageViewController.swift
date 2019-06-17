//
//  LandingPageViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LandingPageViewController: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var facebookLogin: FBLoginButton!
    var db : Firestore?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLogin.delegate = self
        // Do any additional setup after loading the view.
        facebookLogin.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        facebookLogin.clipsToBounds = true
        facebookLogin.layer.cornerRadius = 16
        // Obtain all constraints for the button:
        let layoutConstraintsArr = facebookLogin.constraints
        // Iterate over array and test constraints until we find the correct one:
        for lc in layoutConstraintsArr { // or attribute is NSLayoutAttributeHeight etc.
            if ( lc.constant == 28 ){
                // Then disable it...
                lc.isActive = false
                
                break
            }
        }
        loginButton.layer.cornerRadius = 16
        registerButton.layer.cornerRadius = 16
        db = Firestore.firestore()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.loginSuccessful()
            }
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            if let tokenString = AccessToken.current?.tokenString {
             let credential =  FacebookAuthProvider.credential(withAccessToken: tokenString)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        // User is signed in
                        // ...
                        print("login successful")
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func loginSuccessful() {
        print("Login successful")
        guard let currentUserRef = self.db?.collection("users").document(Auth.auth().currentUser!.uid) else {fatalError()}
        currentUserRef.getDocument(completion: { (document, error) in
            if let document = document {
                if let dataDescription = document.data().map(String.init(describing:)) {
                    print("Cached document data: \(dataDescription)")
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                } else {
                    print("data description is nil")
                    self.performSegue(withIdentifier: "goToSetup", sender: self)
                }
            } else {
                print("Document does not exist in cache")
                self.performSegue(withIdentifier: "goToSetup", sender: self)
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) { }
}
