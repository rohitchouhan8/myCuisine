//
//  LoginViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 8
        loginButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            //TODO: Log in the user
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error!)
                } else {
                    print("Login successful")
                    let currentUserRef = self.db.collection("users").document(Auth.auth().currentUser!.uid)
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
                SVProgressHUD.dismiss()
            }
        }
    }
}
